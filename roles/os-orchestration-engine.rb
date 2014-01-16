name "os-orchestration-engine"
description "heat engine"
run_list(
  "role[os-base]",
  "recipe[openstack-orchestration::engine]"
)
