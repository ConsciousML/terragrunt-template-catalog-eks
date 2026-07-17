<!-- BEGIN_TF_DOCS -->
# AWS Cost Anomaly Detection Module

This module creates a Cost Anomaly Detection monitor and alert subscription that emails a notification whenever a detected spend anomaly's cost impact reaches or exceeds a configured USD threshold. Unlike a fixed-threshold budget, it flags spend that's unusual relative to the account's own historical pattern.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ce_anomaly_monitor.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_monitor) | resource |
| [aws_ce_anomaly_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_anomaly_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_emails"></a> [emails](#input\_emails) | Email addresses notified when an anomaly reaches or exceeds threshold\_usd | `list(string)` | `[]` | no |
| <a name="input_frequency"></a> [frequency](#input\_frequency) | How often anomaly alerts are sent. Valid values: DAILY, IMMEDIATE, WEEKLY | `string` | `"DAILY"` | no |
| <a name="input_monitor_dimension"></a> [monitor\_dimension](#input\_monitor\_dimension) | The dimension the monitor evaluates for anomalies | `string` | `"SERVICE"` | no |
| <a name="input_monitor_name"></a> [monitor\_name](#input\_monitor\_name) | Name of the Cost Anomaly Detection monitor | `string` | `"anomaly-monitor"` | no |
| <a name="input_subscription_name"></a> [subscription\_name](#input\_subscription\_name) | Name of the Cost Anomaly Detection alert subscription | `string` | `"anomaly-subscription"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the monitor and subscription | `map(string)` | `{}` | no |
| <a name="input_threshold_usd"></a> [threshold\_usd](#input\_threshold\_usd) | The dollar impact an anomaly must reach or exceed before triggering a notification | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_monitor_arn"></a> [monitor\_arn](#output\_monitor\_arn) | The ARN of the Cost Anomaly Detection monitor |
| <a name="output_subscription_arn"></a> [subscription\_arn](#output\_subscription\_arn) | The ARN of the Cost Anomaly Detection alert subscription |
<!-- END_TF_DOCS -->