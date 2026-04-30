<!-- BEGIN_TF_DOCS -->
# tailscale\_split\_dns

Configures Tailscale Split DNS to forward DNS queries for a private domain to the VPC DNS resolver, enabling resolution of private Route53 records from the tailnet.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | ~> 0.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | ~> 0.28.0 |

## Resources

| Name | Type |
|------|------|
| [tailscale_dns_split_nameservers.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/dns_split_nameservers) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | The domain suffix whose DNS queries will be forwarded to the nameservers | `string` | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | List of nameserver IPs to forward DNS queries to | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->