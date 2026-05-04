<!-- BEGIN_TF_DOCS -->
# tailscale\_oauth\_client

Creates a Tailscale OAuth client with configurable scopes and tags.
The outputs (`client_id`, `client_secret`) can be used to authenticate with the Tailscale API.

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
| [tailscale_oauth_client.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/oauth_client) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | A description of the OAuth client | `string` | n/a | yes |
| <a name="input_scopes"></a> [scopes](#input\_scopes) | Scopes to grant to the client. See https://tailscale.com/kb/1623/ for available scopes. | `set(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that access tokens generated for the OAuth client will be able to assign to devices. Mandatory when scopes include 'devices:core' or 'auth\_keys'. | `set(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The OAuth client ID |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | The OAuth client secret |
<!-- END_TF_DOCS -->