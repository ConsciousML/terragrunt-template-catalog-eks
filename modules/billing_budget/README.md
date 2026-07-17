<!-- BEGIN_TF_DOCS -->
# AWS Billing Alarm Module

This module creates a CloudWatch alarm on estimated AWS charges for each threshold provided, all notifying a shared SNS topic with optional email subscriptions.

`AWS/Billing` metric data is only published in `us-east-1` and requires the "Receive CloudWatch Billing Alerts" account preference to be enabled once via the Billing console, this module cannot enable it.

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
| [aws_cloudwatch_metric_alarm.estimated_charges](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_name_prefix"></a> [alarm\_name\_prefix](#input\_alarm\_name\_prefix) | Prefix used for the SNS topic name and each CloudWatch alarm name | `string` | `"estimated-charges"` | no |
| <a name="input_datapoints_to_alarm"></a> [datapoints\_to\_alarm](#input\_datapoints\_to\_alarm) | The number of data points that must be breaching to trigger each alarm | `number` | `1` | no |
| <a name="input_emails"></a> [emails](#input\_emails) | Email addresses to subscribe to the billing alarm SNS topic. Each address must confirm the subscription before receiving alerts. | `list(string)` | `[]` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to each threshold | `number` | `1` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the EstimatedCharges statistic is applied | `number` | `3600` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the SNS topic and CloudWatch alarms | `map(string)` | `{}` | no |
| <a name="input_thresholds_usd"></a> [thresholds\_usd](#input\_thresholds\_usd) | USD amounts that each trigger their own CloudWatch alarm on estimated charges | `list(number)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | A map of threshold (USD) to the ARN of its CloudWatch alarm |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic notified by every billing alarm |
<!-- END_TF_DOCS -->