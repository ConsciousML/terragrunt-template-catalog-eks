resource "aws_ce_anomaly_monitor" "this" {
  count = var.monitor_arn == null ? 1 : 0

  name              = var.monitor_name
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = var.monitor_dimension
  tags              = var.tags
}

resource "aws_ce_anomaly_subscription" "this" {
  name      = var.subscription_name
  frequency = var.frequency

  monitor_arn_list = [coalesce(var.monitor_arn, try(aws_ce_anomaly_monitor.this[0].arn, null))]

  dynamic "subscriber" {
    for_each = toset(var.emails)
    content {
      type    = "EMAIL"
      address = subscriber.value
    }
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = [tostring(var.threshold_usd)]
    }
  }

  tags = var.tags
}
