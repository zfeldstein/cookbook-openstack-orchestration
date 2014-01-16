name "os-orchestration-api"
description "heat api"
run_list(
  "role[os-base]",
  "recipe[openstack-orchestration::api]"
)

