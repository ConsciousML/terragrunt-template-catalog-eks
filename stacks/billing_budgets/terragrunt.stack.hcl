unit "billing_budget" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/billing/budget?ref=${values.version}"
  path   = "billing/budget"

  values = {
    version        = values.version
    thresholds_usd = values.thresholds_usd
    emails         = values.emails
    budget_name    = values.budget_name
    tags           = values.tags
  }
}
