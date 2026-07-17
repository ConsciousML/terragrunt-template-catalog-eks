# Billing Budgets Bootstrap

Creates two AWS Budgets: one that emails a notification for each configured USD threshold whenever actual monthly spend exceeds it, and one that does the same based on forecasted monthly spend, giving an earlier warning.

## Purpose

Run this **once per AWS account** to get visibility into unexpected spend before it grows into a large bill.

### Prerequisite
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

## Deployment

### Configuration

Update the `locals` block in `terragrunt.stack.hcl` in this directory with your thresholds and notification emails:

```hcl
locals {
  thresholds_usd            = [33.3, 66.6, 99.9]
  forecasted_thresholds_usd = [66.6, 133.2, 199.8]
  emails                    = ["you@example.com"]
}
```

### Deploy

From the root directory of this repository, run:

```bash
source .env
cd pipelines/bootstrap/billing_budgets
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

## Module Details

See the [`units/billing`](../../../units/billing/README.md) group README for what each unit provisions.
