# Billing Budgets Bootstrap

Creates an AWS Budget that emails a notification for each configured USD threshold whenever actual monthly spend exceeds it.

## Purpose

Run this **once per AWS account** to get visibility into unexpected spend before it grows into a large bill.

### Prerequisite
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

## Deployment

### Configuration

Update `terragrunt.stack.hcl` in this directory with your thresholds and notification emails:

```hcl
values = {
  thresholds_usd = [33.3, 66.6, 99.9]
  emails         = ["you@example.com"]
  # ... other values can remain as defaults
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
