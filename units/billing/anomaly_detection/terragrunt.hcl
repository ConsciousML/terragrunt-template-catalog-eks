include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/billing_anomaly_detection?ref=${values.version}"
}

inputs = {
  monitor_name      = values.monitor_name
  monitor_dimension = values.monitor_dimension
  monitor_arn       = values.monitor_arn
  subscription_name = values.subscription_name
  threshold_usd     = values.threshold_usd
  frequency         = values.frequency
  emails            = values.emails
  tags              = values.tags
}
