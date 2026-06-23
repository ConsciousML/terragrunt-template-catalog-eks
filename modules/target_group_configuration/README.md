<!-- BEGIN_TF_DOCS -->
# Target Group Configuration

Creates a [`TargetGroupConfiguration`](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/targetgroupconfig/) CRD resource used by the AWS Load Balancer Controller to configure target group properties (target type, health checks, protocol) for a `Gateway` or `HTTPRoute`.

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
| <a name="input_name"></a> [name](#input\_name) | Name of the TargetGroupConfiguration resource | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy the TargetGroupConfiguration into | `string` | n/a | yes |
| <a name="input_spec"></a> [spec](#input\_spec) | Full spec of the TargetGroupConfiguration resource | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the TargetGroupConfiguration resource |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace the TargetGroupConfiguration was deployed into |
<!-- END_TF_DOCS -->