<!-- BEGIN_TF_DOCS -->
# AWS External Secret Store

Creates a namespaced ESO [`SecretStore`](https://external-secrets.io/latest/api/secretstore/) backed by AWS Secrets Manager. Authentication is handled transparently via EKS Pod Identity — no static credentials required.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 2.4 |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.this](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region where the Secrets Manager secrets reside | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the SecretStore resource | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the SecretStore into | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the SecretStore resource |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the SecretStore was deployed into |
<!-- END_TF_DOCS -->