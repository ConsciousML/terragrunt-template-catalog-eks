unit "billing_alarm" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/billing/alarm?ref=${values.version}"
  path   = "billing/alarm"

  values = {
    version             = values.version
    thresholds_usd      = values.thresholds_usd
    emails              = values.emails
    alarm_name_prefix   = values.alarm_name_prefix
    period              = values.period
    evaluation_periods  = values.evaluation_periods
    datapoints_to_alarm = values.datapoints_to_alarm
    tags                = values.tags
  }
}
