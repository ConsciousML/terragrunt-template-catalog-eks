output "monitor_arn" {
  description = "The ARN of the Cost Anomaly Detection monitor, whether created by this module or reused via var.monitor_arn"
  value       = coalesce(var.monitor_arn, try(aws_ce_anomaly_monitor.this[0].arn, null))
}

output "subscription_arn" {
  description = "The ARN of the Cost Anomaly Detection alert subscription"
  value       = aws_ce_anomaly_subscription.this.arn
}
