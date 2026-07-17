output "sns_topic_arn" {
  description = "The ARN of the SNS topic notified by every billing alarm"
  value       = aws_sns_topic.this.arn
}

output "alarm_arns" {
  description = "A map of threshold (USD) to the ARN of its CloudWatch alarm"
  value       = { for threshold, alarm in aws_cloudwatch_metric_alarm.estimated_charges : threshold => alarm.arn }
}
