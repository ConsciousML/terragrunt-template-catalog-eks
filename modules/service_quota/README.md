<!-- BEGIN_TF_DOCS -->
# AWS Service Quota Module

This module requests an increase for a single AWS Service Quota via `aws_servicequotas_service_quota`. `service_code` and `quota_code` identify the quota (e.g. `ec2` / `L-1216C47A` for On-Demand Standard vCPUs); `desired_value` is the requested value.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 6.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 6.55.0 |

## Resources

| Name | Type |
|------|------|
| [aws_servicequotas_service_quota.this](https://registry.terraform.io/providers/hashicorp/aws/6.55.0/docs/resources/servicequotas_service_quota) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_desired_value"></a> [desired\_value](#input\_desired\_value) | Requested value for the quota | `number` | n/a | yes |
| <a name="input_quota_code"></a> [quota\_code](#input\_quota\_code) | AWS Service Quota code to request an increase for, e.g. "L-1216C47A" | `string` | n/a | yes |
| <a name="input_service_code"></a> [service\_code](#input\_service\_code) | AWS service code the quota belongs to, e.g. "ec2" | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Service Quota request |
| <a name="output_status"></a> [status](#output\_status) | The status of the quota increase request (PENDING, CASE\_OPENED, APPROVED, ...) |
<!-- END_TF_DOCS -->