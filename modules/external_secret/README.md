<!-- BEGIN_TF_DOCS -->
# External Secret

Creates an ESO [`ExternalSecret`](https://external-secrets.io/latest/api/externalsecret/) that syncs fields from an external secret store into a Kubernetes Secret.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 3.0.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 3.0.1 |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_data"></a> [data](#input\_data) | Mappings from Secrets Manager fields to Kubernetes Secret keys | <pre>list(object({<br/>    secret_key      = string<br/>    remote_key      = string<br/>    remote_property = string<br/>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the ExternalSecret resource | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the ExternalSecret lives | `string` | n/a | yes |
| <a name="input_refresh_policy"></a> [refresh\_policy](#input\_refresh\_policy) | Controls when ESO re-syncs the secret — CreatedOnce, Periodic, or OnChange | `string` | `"CreatedOnce"` | no |
| <a name="input_secret_store_kind"></a> [secret\_store\_kind](#input\_secret\_store\_kind) | Kind of the secret store — SecretStore or ClusterSecretStore | `string` | `"SecretStore"` | no |
| <a name="input_secret_store_name"></a> [secret\_store\_name](#input\_secret\_store\_name) | Name of the SecretStore or ClusterSecretStore to reference | `string` | n/a | yes |
| <a name="input_target_creation_policy"></a> [target\_creation\_policy](#input\_target\_creation\_policy) | Controls whether ESO creates or merges into the target Secret | `string` | `"Merge"` | no |
| <a name="input_target_secret_name"></a> [target\_secret\_name](#input\_target\_secret\_name) | Name of the Kubernetes Secret to write into | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the Kubernetes Secret lives in |
| <a name="output_secret_key"></a> [secret\_key](#output\_secret\_key) | Key written into the target Kubernetes Secret by the first data mapping |
| <a name="output_target_secret_name"></a> [target\_secret\_name](#output\_target\_secret\_name) | Name of the Kubernetes Secret ESO writes into |
<!-- END_TF_DOCS -->