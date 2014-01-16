name "os-orchestration-setup"
description "heat setup"
run_list(
  "role[os-base]",
  "recipe[openstack-orchestration::setup]"
)
