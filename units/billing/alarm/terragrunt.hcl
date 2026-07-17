include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/billing_alarm?ref=${values.version}"
}

inputs = {
  thresholds_usd      = values.thresholds_usd
  emails              = values.emails
  alarm_name_prefix   = values.alarm_name_prefix
  period              = values.period
  evaluation_periods  = values.evaluation_periods
  datapoints_to_alarm = values.datapoints_to_alarm
  tags                = values.tags
}
