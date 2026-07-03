<!-- BEGIN_TF_DOCS -->
# tailscale\_connector

Deploys a Tailscale `Connector` custom resource that runs a subnet router StatefulSet, advertising private subnet CIDRs into the tailnet.

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
| [kubectl_manifest.connector](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advertise_routes"></a> [advertise\_routes](#input\_advertise\_routes) | List of subnet CIDRs to advertise into the tailnet | `list(string)` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_hostname_prefix"></a> [hostname\_prefix](#input\_hostname\_prefix) | Hostname prefix for the connector device in the tailnet | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Connector resource | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | Number of connector replicas | `number` | `1` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->