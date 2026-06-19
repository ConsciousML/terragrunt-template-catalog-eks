<!-- BEGIN_TF_DOCS -->
# Gateway Class

Creates a cluster-scoped [`GatewayClass`](https://gateway-api.sigs.k8s.io/reference/api-types/gatewayclass/) resource that registers a controller as the implementor for `Gateway` resources referencing this class.

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
| <a name="input_controller_name"></a> [controller\_name](#input\_controller\_name) | Name of the controller that manages this GatewayClass (e.g. gateway.k8s.aws/alb) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the GatewayClass | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Name of the GatewayClass |
<!-- END_TF_DOCS -->