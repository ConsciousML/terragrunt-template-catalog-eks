<!-- BEGIN_TF_DOCS -->
# tailscale\_wif

Creates a Tailscale federated identity backed by GitHub Actions OIDC, enabling CI runners to join the tailnet without long-lived credentials.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | = 0.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | = 0.28.0 |

## Resources

| Name | Type |
|------|------|
| [tailscale_federated_identity.this](https://registry.terraform.io/providers/tailscale/tailscale/0.28.0/docs/resources/federated_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_issuer"></a> [issuer](#input\_issuer) | OIDC issuer URL for the federated identity | `string` | n/a | yes |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | OAuth scopes for auth keys issued via this federated identity | `set(string)` | <pre>[<br/>  "devices:core",<br/>  "auth_keys",<br/>  "dns"<br/>]</pre> | no |
| <a name="input_subject"></a> [subject](#input\_subject) | OIDC subject claim pattern (e.g. repo:<org>/<repo>:*) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags assigned to devices authenticated via this federated identity | `set(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_audience"></a> [audience](#output\_audience) | The WIF audience value (api.tailscale.com/<client\_id>) |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The WIF OAuth client ID |
<!-- END_TF_DOCS -->