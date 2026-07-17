resource "aws_sns_topic" "this" {
  name = "${var.alarm_name_prefix}-alarms"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.emails)
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  for_each = toset(var.thresholds_usd)

  alarm_name          = "${var.alarm_name_prefix}-gt-${each.value}usd"
  alarm_description   = "Triggers when estimated AWS charges exceed $${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.datapoints_to_alarm
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = var.period
  statistic           = "Maximum"
  threshold           = each.value
  treat_missing_data  = "missing"
  alarm_actions       = [aws_sns_topic.this.arn]
  ok_actions          = [aws_sns_topic.this.arn]

  dimensions = {
    Currency = "USD"
  }

  tags = var.tags
}
