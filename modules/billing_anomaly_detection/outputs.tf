output "monitor_arn" {
  description = "The ARN of the Cost Anomaly Detection monitor"
  value       = aws_ce_anomaly_monitor.this.arn
}

output "subscription_arn" {
  description = "The ARN of the Cost Anomaly Detection alert subscription"
  value       = aws_ce_anomaly_subscription.this.arn
}
