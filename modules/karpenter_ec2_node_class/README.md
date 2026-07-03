<!-- BEGIN_TF_DOCS -->
# Karpenter EC2NodeClass

Creates an [EC2NodeClass](https://karpenter.sh/docs/concepts/nodeclasses/) custom resource that defines the node configuration for Karpenter-provisioned nodes and outputs its name.

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
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the EC2NodeClass | `string` | n/a | yes |
| <a name="input_spec"></a> [spec](#input\_spec) | Full spec of the EC2NodeClass | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the EC2NodeClass |
<!-- END_TF_DOCS -->