# Billing Alarms Bootstrap

Creates a CloudWatch alarm on estimated AWS charges for each configured USD threshold. You'll receive an email alert whenever your account's estimated charges cross one of those thresholds.

## Purpose

Run this **once per AWS account** to get visibility into unexpected spend before it grows into a large bill.

### Prerequisite
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included), then enable billing alerts as described above.


`AWS/Billing` metric data is only published in `us-east-1`, regardless of where the rest of the account's resources live. `pipelines/region.hcl` defaults to `us-east-1`, so no extra configuration is needed unless that default is changed for a fork, in which case this pipeline must still target `us-east-1`.

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
cd pipelines/bootstrap/billing_alarms
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

### Confirm the email subscription

Each address in `emails` receives an SNS confirmation email. Alerts won't be delivered until that subscription is confirmed.

## Module Details

See the [`units/billing`](../../../units/billing/README.md) group README for what each unit provisions.
