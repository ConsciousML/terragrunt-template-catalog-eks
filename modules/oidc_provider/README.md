<!-- BEGIN_TF_DOCS -->
# AWS OpenID Connect (OIDC) Module

This module creates or retrieves an existing OIDC provider in AWS to connect GitHub Actions with AWS.

The `create` argument is crucial. If this module was used using `create=true`, subsequent use of this module must use `create=false`.

AWS does not allows to create two OIDC providers with the same url.

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
| [aws_iam_openid_connect_provider.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_openid_connect_provider.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id_list"></a> [client\_id\_list](#input\_client\_id\_list) | List of client IDs (audiences) that can request tokens from the OIDC provider | `list(string)` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create or retrieve an existing OIDC provider using a data source | `bool` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the OIDC provider | `map(string)` | `{}` | no |
| <a name="input_thumbprint_list"></a> [thumbprint\_list](#input\_thumbprint\_list) | List of server certificate thumbprints. Optional for GitHub Actions as it's in AWS's trusted CA library | `list(string)` | n/a | yes |
| <a name="input_url"></a> [url](#input\_url) | The URL of the identity provider. Corresponds to the iss claim | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the OIDC provider (used in IAM role trust policies) |
<!-- END_TF_DOCS -->