# Billing

Provisions account-level cost safeguards that alert when spend crosses a defined threshold, independent of any single environment or cluster.

Run via [`pipelines/bootstrap/billing_alarms`](../../pipelines/bootstrap/billing_alarms/) once per AWS account.

## What's Inside

- **[alarm](alarm/)**: Creates a CloudWatch alarm on estimated AWS charges for each configured USD threshold, notifying a shared SNS topic with optional email subscriptions
