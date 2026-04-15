<!-- BEGIN_TF_DOCS -->
# AWS Route53 Hosted Zone Module

This module creates a Route53 public hosted zone for a given domain name.

After applying, retrieve the `name_servers` output and add all 4 NS records to your domain registrar before running any stack that depends on DNS validation (e.g. ACM certificate issuance).

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
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_comment"></a> [comment](#input\_comment) | A comment for the hosted zone | `string` | `"Managed by Terraform"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the hosted zone (e.g. example.com) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the hosted zone | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name_servers"></a> [name\_servers](#output\_name\_servers) | The list of name servers for the hosted zone (delegate these to your domain registrar) |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The hosted zone ID |
<!-- END_TF_DOCS -->