name "os-orchestration-all"
description "heat all in one"
run_list(
  "role[os-orchestration-setup]",
  "role[os-orchestration-engine]",
  "role[os-orchestration-api]",
  "role[os-orchestration-api-cfn]",
  "role[os-orchestration-api-cloudwatch]"
)
