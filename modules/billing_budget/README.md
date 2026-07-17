<!-- BEGIN_TF_DOCS -->
# AWS Billing Budget Module

This module creates an AWS Budget that sends an email notification for each configured USD threshold whenever monthly spend crosses it. Set `notification_type` to `"ACTUAL"` or `"FORECASTED"` depending on whether thresholds should compare against actual or forecasted spend.

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
| [aws_budgets_budget.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_budget_name"></a> [budget\_name](#input\_budget\_name) | Name of the AWS Budget | `string` | `"estimated-charges"` | no |
| <a name="input_emails"></a> [emails](#input\_emails) | Email addresses notified when actual spend crosses a configured threshold | `list(string)` | `[]` | no |
| <a name="input_notification_type"></a> [notification\_type](#input\_notification\_type) | Whether each threshold notification fires on ACTUAL or FORECASTED spend | `string` | n/a | yes |
| <a name="input_thresholds_usd"></a> [thresholds\_usd](#input\_thresholds\_usd) | USD amounts that each trigger their own notification when actual monthly spend exceeds them | `list(number)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget_arn"></a> [budget\_arn](#output\_budget\_arn) | The ARN of the AWS Budget |
| <a name="output_budget_id"></a> [budget\_id](#output\_budget\_id) | The ID of the AWS Budget |
<!-- END_TF_DOCS -->