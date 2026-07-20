<!-- BEGIN_TF_DOCS -->
# AWS Route53 Hosted Zone Module

This module creates or looks up a Route53 hosted zone. Supports both public zones (internet-facing, requires NS delegation for ACM validation) and private zones (VPC-scoped, no delegation required).

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
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/6.55.0/docs/resources/route53_zone) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/6.55.0/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment"></a> [comment](#input\_comment) | A comment for the hosted zone | `string` | `"Managed by Terraform"` | no |
| <a name="input_create"></a> [create](#input\_create) | If true, create the hosted zone. If false, look it up via data source (zone must already exist). | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the hosted zone (e.g. example.com) | `string` | n/a | yes |
| <a name="input_private_zone"></a> [private\_zone](#input\_private\_zone) | If true, the hosted zone is private. Used for data source lookup when create = false. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the hosted zone | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to associate with the hosted zone. When set, the created zone is private. Only used when create = true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The full domain name of the hosted zone |
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | The list of name servers for the hosted zone (delegate these to your domain registrar) |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The hosted zone ID |
<!-- END_TF_DOCS -->