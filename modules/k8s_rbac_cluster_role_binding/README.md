<!-- BEGIN_TF_DOCS -->
# Kubernetes ClusterRoleBinding

Creates a [`ClusterRoleBinding`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) that binds a ClusterRole to one or more subjects at the cluster level.

Terraform resource: [`kubernetes_cluster_role_binding`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding)

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
| [kubernetes_cluster_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Unstructured key value map stored with the ClusterRoleBinding for arbitrary metadata. | `map(string)` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_generate_name"></a> [generate\_name](#input\_generate\_name) | Prefix used by the server to generate a unique name when name is not provided. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Map of string keys and values used to organize and categorize the ClusterRoleBinding. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ClusterRoleBinding. Cannot be updated. | `string` | `null` | no |
| <a name="input_role_ref"></a> [role\_ref](#input\_role\_ref) | References the ClusterRole to bind. | <pre>object({<br/>    api_group = string<br/>    kind      = string<br/>    name      = string<br/>  })</pre> | n/a | yes |
| <a name="input_subjects"></a> [subjects](#input\_subjects) | Entities to bind the ClusterRole to. | <pre>list(object({<br/>    kind      = string<br/>    name      = string<br/>    api_group = optional(string)<br/>    namespace = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the created ClusterRoleBinding |
<!-- END_TF_DOCS -->