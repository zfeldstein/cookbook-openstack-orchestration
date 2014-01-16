name "os-orchestration-api-cloudwatch"
description "heat cloudwatch api"
run_list(
  "role[os-base]",
  "recipe[openstack-orchestration::api-cloudwatch]"
)


