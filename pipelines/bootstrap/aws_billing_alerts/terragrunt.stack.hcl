locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  # Edit these before deploying
  thresholds_usd            = [33.3, 66.6, 99.9]
  forecasted_thresholds_usd = [66.6, 133.2, 199.8]
  emails                    = ["axelmendoza@hotmail.fr"]

  # See docs/environment-variables.md#billing_anomaly_monitor_arn
  monitor_arn_env = get_env("BILLING_ANOMALY_MONITOR_ARN", "")
  monitor_arn     = local.monitor_arn_env != "" ? local.monitor_arn_env : null
}

stack "billing_budgets" {
  source = "github.com/${local.github_owner_catalog}/${local.github_repo_name_catalog}//stacks/billing_budgets?ref=${local.version}"
  path   = "billing_budgets"
  values = {
    version = local.version

    thresholds_usd            = local.thresholds_usd
    forecasted_thresholds_usd = local.forecasted_thresholds_usd
    emails                    = local.emails

    budget_name            = "estimated-charges"
    forecasted_budget_name = "estimated-charges-forecast"
    tags                   = {}
  }
}

stack "billing_anomaly_detection" {
  source = "github.com/${local.github_owner_catalog}/${local.github_repo_name_catalog}//stacks/billing_anomaly_detection?ref=${local.version}"
  path   = "billing_anomaly_detection"
  values = {
    version = local.version

    # Edit these before deploying
    monitor_name      = "anomaly-monitor"
    monitor_dimension = "SERVICE"
    monitor_arn       = local.monitor_arn
    subscription_name = "anomaly-subscription"
    threshold_usd     = 3
    frequency         = "DAILY"
    emails            = local.emails

    tags = {}
  }
}
