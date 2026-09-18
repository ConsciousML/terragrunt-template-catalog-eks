{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS Billing Anomaly Detection Bootstrap

The [`billing_anomaly_detection` stack](../../stacks/billing_anomaly_detection/), deployed by the [`aws_billing_alerts` pipeline](../../pipelines/bootstrap/aws_billing_alerts/), creates an [AWS Cost Anomaly Detection](https://aws.amazon.com/aws-cost-management/aws-cost-anomaly-detection/) monitor and subscription that emails a notification when a detected spend anomaly's cost impact reaches or exceeds a configured USD threshold, independent of any fixed budget.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/aws_billing_alerts).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `billing_anomaly_detection` | [`units/billing/anomaly_detection`](../../units/billing/anomaly_detection/) | [`modules/billing_anomaly_detection`](../../modules/billing_anomaly_detection/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `monitor_name` | Name of the Cost Anomaly Detection monitor. Only used if one is created, see [Anomaly Monitor](#anomaly-monitor). | `string` | `"anomaly-monitor"` | No |
| `monitor_dimension` | Dimension the monitor evaluates for anomalies: `SERVICE`, `LINKED_ACCOUNT`, `COST_CATEGORY`, or `TAG`. Ignored when `monitor_arn` is set. | `string` | `"SERVICE"` | No |
| `monitor_arn` | ARN of an existing Cost Anomaly Detection monitor to subscribe to instead of creating a new one. See [Anomaly Monitor](#anomaly-monitor). | `string` | `null` | No |
| `subscription_name` | Name of the Cost Anomaly Detection alert subscription. | `string` | `"anomaly-subscription"` | No |
| `threshold_usd` | Minimum anomaly cost impact (USD) that triggers a notification. | `number` | - | Yes |
| `frequency` | How often anomaly alerts are sent: `DAILY`, `WEEKLY`, or `IMMEDIATE` (requires an SNS subscriber, not email). | `string` | `"DAILY"` | No |
| `emails` | Email addresses notified when an anomaly reaches or exceeds `threshold_usd`. | `list(string)` | `[]` | No |
| `tags` | Tags applied to the monitor and subscription. | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
|------|-------------|
| `monitor_arn` | The ARN of the Cost Anomaly Detection monitor, whether created by this module or reused via `monitor_arn`. |
| `subscription_arn` | The ARN of the Cost Anomaly Detection alert subscription. |

## Anomaly Monitor

AWS allows only one `DIMENSIONAL` monitor per dimension per account, and auto-creates a `SERVICE` one, so a fresh `SERVICE` monitor often can't be created. Find an existing one with `aws ce get-anomaly-monitors` and set `monitor_arn` (also settable via `BILLING_ANOMALY_MONITOR_ARN`, see the [environment variables reference](/docs/reference/environment_variable/#billing_anomaly_monitor_arn)) instead of creating a new one.
