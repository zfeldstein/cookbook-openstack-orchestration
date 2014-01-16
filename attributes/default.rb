#
# Cookbook Name:: heat
# attributes:: default
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

default["openstack"]["orchestration"]["db"]["name"] = "heat"
default["openstack"]["orchestration"]["db"]["username"] = "heat"

default["openstack"]["orchestration"]["service_tenant_name"] = "service"
default["openstack"]["orchestration"]["service_user"] = "heat"
default["openstack"]["orchestration"]["service_role"] = "admin"

default["openstack"]["orchestration"]["ssl"]["enabled"] = false
default["openstack"]["orchestration"]["ssl"]["ca_file"] = nil
default["openstack"]["orchestration"]["ssl"]["cert_file"] = "heat.pem"
default["openstack"]["orchestration"]["ssl"]["key_file"] = "heat.key"
default["openstack"]["orchestration"]["ssl"]["dir"] = "/etc/heat/certs"

# Options are no_op, rpc, log
default["openstack"]["orchestration"]["notification"]["driver"] = "no_op"
default["openstack"]["orchestration"]["notification"]["topics"] = "notifications"

# policy
default["openstack"]["orchestration"]["policy_file"] = "policy.json"
default["openstack"]["orchestration"]["policy_default_rule"] = "default"

# Heartbeat
default["openstack"]["orchestration"]["heartbeat"]["freq"] = 300
default["openstack"]["orchestration"]["heartbeat"]["ttl"] = 600

# Default SQL Stuffs
default["openstack"]["orchestration"]["sql"]["backend"] = "sqlalchemy"
default["openstack"]["orchestration"]["sql"]["max_retries"] = 10
default["openstack"]["orchestration"]["sql"]["retry_interval"] = 10

# Salve Database Stuffs
default["openstack"]["orchestration"]["sql"]["slave"]["enabled"] = false
default["openstack"]["orchestration"]["sql"]["slave"]["salve_user"] = nil
default["openstack"]["orchestration"]["sql"]["slave"]["salve_password"] = nil
default["openstack"]["orchestration"]["sql"]["slave"]["salve_host"] = nil
default["openstack"]["orchestration"]["sql"]["slave"]["salve_db"] = "mysql"

# Max Template Size
default["openstack"]["orchestration"]["template_size"] =  20480

# Heat Engine
default["openstack"]["orchestration"]["services"]["engine"]["name"] = "heat"

# Cloud Watch API
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["enabled"] = true
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["network"] = "public"
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["port"] = 8003
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["path"] = ""

default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["backlog"] = 4096
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["cert"] = "heat.pem"
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["key"] = "heat.key"
default["openstack"]["orchestration"]["services"]["cloudwatch_api"]["workers"] = 10

# Cloud Formation API
default["openstack"]["orchestration"]["services"]["cfn_api"]["enabled"] = true
default["openstack"]["orchestration"]["services"]["cfn_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["cfn_api"]["network"] = "public"
default["openstack"]["orchestration"]["services"]["cfn_api"]["port"] = 8000
default["openstack"]["orchestration"]["services"]["cfn_api"]["path"] = "/v1/$(tenant_id)s"

default["openstack"]["orchestration"]["services"]["cfn_api"]["backlog"] = 4096
default["openstack"]["orchestration"]["services"]["cfn_api"]["cert"] = "heat.pem"
default["openstack"]["orchestration"]["services"]["cfn_api"]["key"] = "heat.key"
default["openstack"]["orchestration"]["services"]["cfn_api"]["workers"] = 10

default["openstack"]["orchestration"]["services"]["cfn_internal_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["cfn_internal_api"]["network"] = "management"
default["openstack"]["orchestration"]["services"]["cfn_internal_api"]["port"] = 8000
default["openstack"]["orchestration"]["services"]["cfn_internal_api"]["path"] = "/v1/$(tenant_id)s"

default["openstack"]["orchestration"]["services"]["cfn_admin_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["cfn_admin_api"]["network"] = "management"
default["openstack"]["orchestration"]["services"]["cfn_admin_api"]["port"] = 8000
default["openstack"]["orchestration"]["services"]["cfn_admin_api"]["path"] = "/v1/$(tenant_id)s"

# Heat API
default["openstack"]["orchestration"]["services"]["base_api"]["enabled"] = true
default["openstack"]["orchestration"]["services"]["base_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["base_api"]["network"] = "public"
default["openstack"]["orchestration"]["services"]["base_api"]["port"] = 8004
default["openstack"]["orchestration"]["services"]["base_api"]["path"] = "/v1/$(tenant_id)s"

default["openstack"]["orchestration"]["services"]["base_api"]["backlog"] = 4096
default["openstack"]["orchestration"]["services"]["base_api"]["cert"] = "heat.pem"
default["openstack"]["orchestration"]["services"]["base_api"]["key"] = "heat.key"
default["openstack"]["orchestration"]["services"]["base_api"]["workers"] = 10

default["openstack"]["orchestration"]["services"]["base_internal_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["base_internal_api"]["network"] = "management"
default["openstack"]["orchestration"]["services"]["base_internal_api"]["port"] = 8004
default["openstack"]["orchestration"]["services"]["base_internal_api"]["path"] = "/v1/$(tenant_id)s"

default["openstack"]["orchestration"]["services"]["base_admin_api"]["scheme"] = "http"
default["openstack"]["orchestration"]["services"]["base_admin_api"]["network"] = "management"
default["openstack"]["orchestration"]["services"]["base_admin_api"]["port"] = 8004
default["openstack"]["orchestration"]["services"]["base_admin_api"]["path"] = "/v1/$(tenant_id)s"

default["openstack"]["orchestration"]["auth_encryption_key"] = "AnyStringWillDoJustFine"
default["openstack"]["orchestration"]["syslog"]["use"] = false
default["openstack"]["orchestration"]["syslog"]["facility"] = "LOG_LOCAL3"

default["openstack"]["orchestration"]["logging"]["debug"] = "false"
default["openstack"]["orchestration"]["logging"]["verbose"] = "true"

# Generic regex for process pattern matching (to be used as a base pattern).
# # Works for both Grizzly and Havana packages on Ubuntu and CentOS.
procmatch_base = '^((/usr/bin/)?python\d? )?(/usr/bin/)?'

case platform_family
when "rhel"
  default["openstack"]["orchestration"]["platform"] = {
    "supporting_packages" => %w[openstack-heat-common MySQL-python python-heatclient],
    "api_package_list" => ["openstack-heat-api"],
    "api_service" => "openstack-heat-api",
    "api_procmatch" => procmatch_base + 'heat-api\b',
    "cfn_api_package_list" => ["openstack-heat-api-cfn"],
    "cfn_api_service" => "openstack-heat-api-cfn",
    "cfn_api_procmatch" => procmatch_base + 'heat-api-cfn\b',
    "cloudwatch_api_package_list" => ["openstack-heat-api-cloudwatch"],
    "cloudwatch_api_service" => "openstack-heat-api-cloudwatch",
    "cloudwatch_api_procmatch" => procmatch_base + 'heat-api-cloudwatch\b',
    "heat_engine_package_list" => ["openstack-heat-engine"],
    "heat_engine_service" => "openstack-heat-engine",
    "heat_engine_procmatch" => procmatch_base + 'heat-engine\b',
    "package_overrides" => ""
  }
when "debian"
  default["openstack"]["orchestration"]["platform"] = {
    "supporting_packages" => %w[heat-common python-heat python-mysqldb python-heatclient],
    "api_package_list" => ["heat-api"],
    "api_service" => "heat-api",
    "api_procmatch" => procmatch_base + 'heat-api\b',
    "cfn_api_package_list" => ["heat-api-cfn"],
    "cfn_api_service" => "heat-api-cfn",
    "cfn_api_procmatch" => procmatch_base + 'heat-api-cfn\b',
    "cloudwatch_api_package_list" => ["heat-api-cloudwatch"],
    "cloudwatch_api_service" => "heat-api-cloudwatch",
    "cloudwatch_api_procmatch" => procmatch_base + 'heat-api-cloudwatch\b',
    "heat_engine_package_list" => ["heat-engine"],
    "heat_engine_service" => "heat-engine",
    "heat_engine_procmatch" => procmatch_base + 'heat-engine\b',
    "service_bin" => "/usr/sbin/service",
    "package_overrides" => "-o Dpkg::Options:='--force-confold' -o Dpkg::Options:='--force-confdef'"
  }
end
