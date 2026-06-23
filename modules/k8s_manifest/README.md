<!-- BEGIN_TF_DOCS -->
# k8s Manifest

Creates a generic Kubernetes manifest resource. Callers supply `api_version`, `kind`, and `spec`; the module applies them via the `kubernetes_manifest` Terraform resource.

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
| <a name="input_api_version"></a> [api\_version](#input\_api\_version) | API version of the Kubernetes resource (e.g. gateway.networking.k8s.io/v1) | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_kind"></a> [kind](#input\_kind) | Kind of the Kubernetes resource (e.g. Gateway, GatewayClass) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Kubernetes resource | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the resource into; omit for cluster-scoped resources | `string` | `null` | no |
| <a name="input_spec"></a> [spec](#input\_spec) | Full spec of the Kubernetes resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the Kubernetes resource |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the resource was deployed into; null for cluster-scoped resources |
<!-- END_TF_DOCS -->