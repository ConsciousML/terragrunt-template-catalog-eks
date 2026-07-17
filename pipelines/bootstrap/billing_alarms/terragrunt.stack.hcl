locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username_catalog  = local.github_locals.github_username_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog
}

stack "billing_alarms" {
  source = "github.com/${local.github_username_catalog}/${local.github_repo_name_catalog}//stacks/billing_alarms?ref=${local.version}"
  path   = "billing_alarms"
  values = {
    version = local.version

    # Edit these before deploying
    thresholds_usd = [33.3, 66.6, 99.9]
    emails         = ["you@example.com"]

    alarm_name_prefix   = "estimated-charges"
    period              = 3600
    evaluation_periods  = 1
    datapoints_to_alarm = 1
    tags                = {}
  }
}
