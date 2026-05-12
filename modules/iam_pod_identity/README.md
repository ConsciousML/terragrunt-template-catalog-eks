<!-- BEGIN_TF_DOCS -->
# IAM Pod Identity

Creates an IAM role and policy, then binds them to a Kubernetes service account via EKS Pod Identity.

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
| [aws_eks_pod_identity_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_iam_policy_json"></a> [iam\_policy\_json](#input\_iam\_policy\_json) | IAM policy document as a JSON string | `string` | n/a | yes |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name of the IAM policy to create | `string` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role to create | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Kubernetes namespace of the service account to associate with the role | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Kubernetes service account name to associate with the role | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the IAM role | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Kubernetes namespace of the associated service account |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN of the IAM policy |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Kubernetes service account name associated with the role |
<!-- END_TF_DOCS -->