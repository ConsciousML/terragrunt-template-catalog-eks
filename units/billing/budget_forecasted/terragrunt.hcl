include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/billing_budget?ref=${values.version}"
}

inputs = {
  thresholds_usd    = values.thresholds_usd
  emails            = values.emails
  budget_name       = values.budget_name
  notification_type = "FORECASTED"
  tags              = values.tags
}
