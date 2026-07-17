# Billing

Provisions account-level cost safeguards that alert when spend crosses a defined threshold, independent of any single environment or cluster.

Run via [`pipelines/bootstrap/aws_billing_alerts`](../../pipelines/bootstrap/aws_billing_alerts/) once per AWS account.

## What's Inside

- **[budget_actual](budget_actual/)**: Creates an AWS Budget that emails a notification for each configured USD threshold whenever actual monthly spend exceeds it
- **[budget_forecasted](budget_forecasted/)**: Same as `budget_actual`, but notifies based on forecasted monthly spend instead, giving an earlier warning
- **[anomaly_detection](anomaly_detection/)**: Creates an AWS Cost Anomaly Detection monitor and subscription that emails a notification when a detected spend anomaly's cost impact reaches or exceeds a configured USD threshold
