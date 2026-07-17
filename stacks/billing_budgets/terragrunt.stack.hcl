unit "billing_budget_actual" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/billing/budget_actual?ref=${values.version}"
  path   = "billing/budget_actual"

  values = {
    version        = values.version
    thresholds_usd = values.thresholds_usd
    emails         = values.emails
    budget_name    = values.budget_name
    tags           = values.tags
  }
}

unit "billing_budget_forecasted" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/billing/budget_forecasted?ref=${values.version}"
  path   = "billing/budget_forecasted"

  values = {
    version        = values.version
    thresholds_usd = values.forecasted_thresholds_usd
    emails         = values.emails
    budget_name    = values.forecasted_budget_name
    tags           = values.tags
  }
}
