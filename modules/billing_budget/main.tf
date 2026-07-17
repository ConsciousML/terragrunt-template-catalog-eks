resource "aws_budgets_budget" "this" {
  name         = var.budget_name
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = max(var.thresholds_usd...)
  limit_unit   = "USD"

  dynamic "notification" {
    for_each = toset(var.thresholds_usd)
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "ABSOLUTE_VALUE"
      notification_type          = var.notification_type
      subscriber_email_addresses = var.emails
    }
  }
}
