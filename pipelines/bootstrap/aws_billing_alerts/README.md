# AWS Billing Alerts Bootstrap

Deploys the [`billing_budgets`](../../../stacks/billing_budgets/) and [`billing_anomaly_detection`](../../../stacks/billing_anomaly_detection/) stacks together:

- Two AWS Budgets: one that emails a notification for each configured USD threshold whenever actual monthly spend exceeds it, and one that does the same based on forecasted monthly spend, giving an earlier warning
- An AWS Cost Anomaly Detection monitor and subscription that emails a notification when a detected spend anomaly's cost impact reaches or exceeds a configured USD threshold, independent of any fixed budget

## Purpose

Run this **once per AWS account** to get visibility into unexpected spend before it grows into a large bill.

### Prerequisite
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included), then set `BILLING_ANOMALY_MONITOR_ARN` in `.env` (see [environment-variables.md](../../../docs/environment-variables.md#billing_anomaly_monitor_arn)).

## Deployment

### Configuration

Update the `locals` block and each `stack` block's `values` in `terragrunt.stack.hcl` in this directory with your thresholds and notification emails:

```hcl
locals {
  thresholds_usd            = [33.3, 66.6, 99.9]
  forecasted_thresholds_usd = [66.6, 133.2, 199.8]
  emails                    = ["you@example.com"]
}

stack "billing_anomaly_detection" {
  values = {
    threshold_usd = 3
    # ...
  }
}
```

### Deploy

From the root directory of this repository, run:

```bash
source .env
cd pipelines/bootstrap/aws_billing_alerts
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

## Module Details

See the [`units/billing`](../../../units/billing/README.md) group README for what each unit provisions.
