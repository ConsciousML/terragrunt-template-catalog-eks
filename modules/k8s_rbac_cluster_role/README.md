<!-- BEGIN_TF_DOCS -->
# Kubernetes ClusterRole

Creates a [`ClusterRole`](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) that grants permissions at the cluster level and across all namespaces.

Terraform resource: [`kubernetes_cluster_role`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role)

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
| [kubernetes_cluster_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aggregation_rule"></a> [aggregation\_rule](#input\_aggregation\_rule) | Describes how to build the Rules for this ClusterRole via label selector aggregation. | <pre>object({<br/>    cluster_role_selectors = list(object({<br/>      match_labels = optional(map(string), {})<br/>      match_expressions = optional(list(object({<br/>        key      = string<br/>        operator = string<br/>        values   = set(string)<br/>      })), [])<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_annotations"></a> [annotations](#input\_annotations) | Unstructured key value map stored with the ClusterRole for arbitrary metadata. | `map(string)` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster | `string` | n/a | yes |
| <a name="input_generate_name"></a> [generate\_name](#input\_generate\_name) | Prefix used by the server to generate a unique name when name is not provided. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Map of string keys and values used to organize and categorize the ClusterRole. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ClusterRole. Cannot be updated. | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | List of PolicyRules for this ClusterRole. | <pre>list(object({<br/>    api_groups = list(string)<br/>    resources  = list(string)<br/>    verbs      = list(string)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the created ClusterRole |
<!-- END_TF_DOCS -->