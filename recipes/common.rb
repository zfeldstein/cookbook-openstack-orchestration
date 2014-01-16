#
# Cookbook Name:: heat
# Recipe:: heat-common
#
# Copyright 2013, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

platform_options = node["openstack"]["orchestration"]["platform"]
#ks_service_endpoint = get_access_endpoint("keystone-api", "keystone", "service-api")
#ks_admin_endpoint = get_access_endpoint("keystone-api", "keystone", "admin-api")
ks_service_endpoint  = endpoint "identity-api"
db_user = node["openstack"]["orchestration"]["db"]["username"]
db_pass = db_password "heat"
mysql_connect_ip = db_uri("heat", db_user, db_pass)

# Get my Rabbit Queues and Settings
rabbit_info = get_access_endpoint("rabbitmq-server", "rabbitmq", "queue")
rabbit_settings = get_settings_by_role("rabbitmq-server", "rabbitmq")

platform_options["supporting_packages"].each do |pkg|
  package pkg do
    action node["osops"]["do_package_upgrades"] == true ? :upgrade : :install
    options platform_options["package_overrides"]
  end
end

# signing dir is here, even for clients
directory "/var/cache/heat" do
  action :create
  owner "heat"
  group "heat"
  mode "700"
end

# signing dir is here, even for clients
directory node["openstack"]["orchestration"]["ssl"]["dir"] do
  action :create
  owner "heat"
  group "heat"
  mode "700"
end

key_location = "#{node["openstack"]["orchestration"]["ssl"]["dir"]}/#{node["openstack"]["orchestration"]["ssl"]["key_file"]}"
cookbook_file key_location do
  source "heat.key"
  mode 0644
  owner "heat"
  group "heat"
end

cert_location = "#{node["openstack"]["orchestration"]["ssl"]["dir"]}/#{node["openstack"]["orchestration"]["ssl"]["cert_file"]}"
cookbook_file cert_location do
  source "heat.pem"
  mode 0644
  owner "heat"
  group "heat"
end

# Set SSL Section
if node["openstack"]["orchestration"]["ssl"]["enabled"] == true
  # CA Location
  unless node["openstack"]["orchestration"]["ssl"].attribute?"ca_override"
    ca_location = "#{node["openstack"]["orchestration"]["ssl"]["dir"]}/#{node["openstack"]["orchestration"]["ssl"]["ca_file"]}"
  else
    ca_location = node["openstack"]["orchestration"]["ssl"]["ca_override"]
  end

  # CERT Location
  if node["openstack"]["orchestration"]["ssl"].attribute?"cert_override"
    cert_location = node["openstack"]["orchestration"]["ssl"]["cert_override"]
  end

  # KEY Location
  if node["openstack"]["orchestration"]["ssl"].attribute?"key_override"
    key_location = node["openstack"]["orchestration"]["ssl"]["key_override"]
  end
else
  ca_location = nil
end

# Check for certificate in enabled API
srvs = node.set["openstack"]["orchestration"]["services"]
apis = ["base_api", "cloudwatch_api", "cfn_api"]
apis.each do |api|
  # SET SERVICE
  service_api = node["openstack"]["orchestration"]["services"][api]

  # CHECK SERVICE API
  if service_api["enabled"] == true
    # CERT PLACEMENT
    unless service_api.attribute?"cert_override"
      srvs[api]["cert_location"] = cert_location
    else
      srvs[api]["cert_location"] = service_api["cert_override"]
    end

    # KEY PLACEMENT
    unless service_api.attribute?"key_override"
      srvs[api]["key_location"] = key_location
    else
      srvs[api]["key_location"] = service_api["key_override"]
    end
  end
end

# SAVE SET ATTRIBUTES
node.save

# Get and shorten our Services attribute objects
service_options = node["openstack"]["orchestration"]["services"]
engine = service_options["engine"]
base_api_options = service_options["base_api"]
cfn_api_options = service_options["cfn_api"]
cw_api_options = service_options["cloudwatch_api"]

heat_api = get_bind_endpoint("heat", "base_api")
heat_cfn_api = get_bind_endpoint("heat", "cfn_api")
heat_cloudwatch_api = get_bind_endpoint("heat", "cloudwatch_api")

# Create Directories
directories = ["/etc/heat/environment.d", "/etc/heat/templates"]
directories.each do |dir|
  directory dir do
    action :create
    owner "heat"
    group "heat"
    mode "755"
  end
end

cookbook_file "/etc/heat/policy.json" do
  source "policy.json"
  owner "heat"
  group "heat"
  mode "0644"
end

cookbook_file "/etc/heat/environment.d/default.yaml" do
  source "environment.default.yaml"
  owner "heat"
  group "heat"
  mode "0644"
end

notification_provider = node["openstack"]["orchestration"]["notification"]["driver"]
case notification_provider
when "no_op"
  notification_driver = "heat.openstack.common.notifier.no_op_notifier"
when "rpc"
  notification_driver = "heat.openstack.common.notifier.rpc_notifier"
when "log"
  notification_driver = "heat.openstack.common.notifier.log_notifier"
else
  msg = "#{notification_provider}, is not currently supported by these cookbooks."
  Chef::Application.fatal! msg
end

template "/etc/heat/heat.conf" do
  source "heat.conf.erb"
  owner "heat"
  group "heat"
  mode "0660"
  variables(
    "template_size" => node["openstack"]["orchestration"]["template_size"],
    "verbose" => node["openstack"]["orchestration"]["logging"]["verbose"],
    "debug" => node["openstack"]["orchestration"]["logging"]["debug"],
    "use_syslog" => node["openstack"]["orchestration"]["syslog"]["use"],
    "syslog_log_facility" => node["openstack"]["orchestration"]["syslog"]["facility"],

    "mysql_user" => node["openstack"]["orchestration"]["db"]["username"],
    "mysql_password" => node["openstack"]["orchestration"]["db"]["password"],
    "mysql_host" => mysql_connect_ip,
    "mysql_db" => node["openstack"]["orchestration"]["db"]["name"],

    "policy_file" => node["openstack"]["orchestration"]["policy_file"],
    "policy_default_rule" => node["openstack"]["orchestration"]["policy_default_rule"],

    "heat_admin" => node["openstack"]["orchestration"]["service_user"],
    "heat_password" => node["openstack"]["orchestration"]["service_pass"],
    "heat_tenant" => node["openstack"]["orchestration"]["service_tenant_name"],

    "heartbeat_ttl" => node["openstack"]["orchestration"]["heartbeat"]["ttl"],
    "heartbeat_freq" => node["openstack"]["orchestration"]["heartbeat"]["freq"],

    "heat_engine_bind" => engine["name"],

    "sql_backend" => node["openstack"]["orchestration"]["sql"]["backend"],
    "sql_max_retries" => node["openstack"]["orchestration"]["sql"]["max_retries"],
    "sql_retry_interval" => node["openstack"]["orchestration"]["sql"]["retry_interval"],
    "slave_db_type" => node["openstack"]["orchestration"]["sql"]["slave"]["salve_db_type"],
    "slave_user" => node["openstack"]["orchestration"]["sql"]["slave"]["salve_user"],
    "slave_password" => node["openstack"]["orchestration"]["sql"]["slave"]["salve_password"],
    "slave_host" => node["openstack"]["orchestration"]["sql"]["slave"]["salve_host"],
    "slave_db" => node["openstack"]["orchestration"]["sql"]["slave"]["salve_db"],

    "ssl_key_file" => key_location,
    "ssl_cert_file" => cert_location,
    "ssl_ca_file" => ca_location,

    "heat_auth_encryption_key" => node["openstack"]["orchestration"]["auth_encryption_key"],

    "heat_api_scheme" => heat_api["scheme"],
    "heat_api_host" => heat_api["host"],
    "heat_api_port" => heat_api["port"],
    "heat_api_backlog" => base_api_options["backlog"],
    "heat_api_cert" => base_api_options["cert_location"],
    "heat_api_key" => base_api_options["key_location"],
    "heat_api_workers" => base_api_options["workers"],

    "heat_api_cfn_scheme" => heat_cfn_api["scheme"],
    "heat_api_cfn_host" => heat_cfn_api["host"],
    "heat_api_cfn_port" => heat_cfn_api["port"],
    "heat_api_cfn_backlog" => cfn_api_options["backlog"],
    "heat_api_cfn_cert" => cfn_api_options["cert_location"],
    "heat_api_cfn_key" => cfn_api_options["key_location"],
    "heat_api_cfn_workers" => cfn_api_options["workers"],

    "heat_api_cloudwatch_scheme" => heat_cloudwatch_api["scheme"],
    "heat_api_cloudwatch_host" => heat_cloudwatch_api["host"],
    "heat_api_cloudwatch_port" => heat_cloudwatch_api["port"],
    "heat_api_cloudwatch_backlog" => cw_api_options["backlog"],
    "heat_api_cloudwatch_cert" => cw_api_options["cert_location"],
    "heat_api_cloudwatch_key" => cw_api_options["key_location"],
    "heat_api_cloudwatch_workers" => cw_api_options["workers"],

    "keystone_service_protocol" => ks_service_endpoint["scheme"],
    "keystone_service_port" => ks_service_endpoint["port"],
    "keystone_service_host" => ks_service_endpoint["host"],
    "keystone_auth_url" => ks_service_endpoint["uri"],
    "keystone_auth_protocol" => ks_admin_endpoint["scheme"],
    "keystone_auth_port" => ks_admin_endpoint["port"],
    "keystone_auth_host" => ks_admin_endpoint["host"],

    "rabbit_host" => rabbit_info["host"],
    "rabbit_port" => rabbit_info["port"],
    "rabbit_ha_queues" => rabbit_settings["cluster"] ? "True" : "False",
    "rabbit_password" => rabbit_settings["default_pass"],
    "rabbit_username" => rabbit_settings["default_user"],
    "notification_driver" => notification_driver,
    "notification_topics" => node["openstack"]["orchestration"]["notification"]["topics"]
  )
end
