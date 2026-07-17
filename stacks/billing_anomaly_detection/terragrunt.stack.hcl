unit "billing_anomaly_detection" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/billing/anomaly_detection?ref=${values.version}"
  path   = "billing/anomaly_detection"

  values = {
    version           = values.version
    monitor_name      = values.monitor_name
    monitor_dimension = values.monitor_dimension
    subscription_name = values.subscription_name
    threshold_usd     = values.threshold_usd
    frequency         = values.frequency
    emails            = values.emails
    tags              = values.tags
  }
}
