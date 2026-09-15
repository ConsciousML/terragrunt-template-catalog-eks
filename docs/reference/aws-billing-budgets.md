{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS Billing Budgets Bootstrap

The [`billing_budgets` stack](../../stacks/billing_budgets/), deployed by the [`aws_billing_alerts` pipeline](../../pipelines/bootstrap/aws_billing_alerts/), creates two [AWS Budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/): one that emails a notification for each configured USD threshold whenever actual monthly spend exceeds it, and one that does the same based on forecasted monthly spend, giving an earlier warning.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/aws_billing_alerts).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `billing_budget_actual` | [`units/billing/budget_actual`](../../units/billing/budget_actual/) | [`modules/billing_budget`](../../modules/billing_budget/) |
| `billing_budget_forecasted` | [`units/billing/budget_forecasted`](../../units/billing/budget_forecasted/) | [`modules/billing_budget`](../../modules/billing_budget/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `thresholds_usd` | USD amounts that each trigger an actual-spend budget notification. | `list(number)` | - | Yes |
| `forecasted_thresholds_usd` | USD amounts that each trigger a forecasted-spend budget notification. | `list(number)` | - | Yes |
| `emails` | Email addresses notified by both budgets. | `list(string)` | `[]` | No |
| `budget_name` | Name of the actual-spend AWS Budget. | `string` | `"estimated-charges"` | No |
| `forecasted_budget_name` | Name of the forecasted-spend AWS Budget. | `string` | `"estimated-charges"` | No |
| `tags` | Tags applied to both budgets. | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
|------|-------------|
| `budget_id` | The ID of the AWS Budget. |
| `budget_arn` | The ARN of the AWS Budget. |
