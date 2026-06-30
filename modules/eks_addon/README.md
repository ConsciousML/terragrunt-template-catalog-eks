<!-- BEGIN_TF_DOCS -->
# EKS Addon

Installs an EKS managed add-on into an existing cluster.

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
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_name"></a> [addon\_name](#input\_addon\_name) | Name of the EKS add-on | `string` | n/a | yes |
| <a name="input_addon_version"></a> [addon\_version](#input\_addon\_version) | Version of the EKS add-on. When null, the latest default version is used. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_configuration_values"></a> [configuration\_values](#input\_configuration\_values) | Custom configuration values for the add-on as a JSON string. | `string` | `null` | no |
| <a name="input_preserve"></a> [preserve](#input\_preserve) | When true, created resources are preserved when the add-on is deleted. | `bool` | `false` | no |
| <a name="input_resolve_conflicts_on_create"></a> [resolve\_conflicts\_on\_create](#input\_resolve\_conflicts\_on\_create) | How to resolve field value conflicts when migrating a self-managed add-on. Valid values: NONE, OVERWRITE. | `string` | `"OVERWRITE"` | no |
| <a name="input_resolve_conflicts_on_update"></a> [resolve\_conflicts\_on\_update](#input\_resolve\_conflicts\_on\_update) | How to resolve field value conflicts when updating the add-on. Valid values: NONE, OVERWRITE, PRESERVE. | `string` | `"OVERWRITE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the add-on. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) of the EKS add-on |
<!-- END_TF_DOCS -->