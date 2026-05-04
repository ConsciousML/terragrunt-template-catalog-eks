<!-- BEGIN_TF_DOCS -->
# tailscale\_github\_secrets

Stores the Tailscale WIF client ID and audience as GitHub Actions secrets, enabling CI to join the tailnet without long-lived credentials.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.6.0 |

## Resources

| Name | Type |
|------|------|
| [github_actions_secret.ts_audience](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.ts_oauth_client_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.ts_tags](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_audience"></a> [audience](#input\_audience) | Tailscale WIF audience value (TS\_AUDIENCE) | `string` | n/a | yes |
| <a name="input_github_repo_name"></a> [github\_repo\_name](#input\_github\_repo\_name) | GitHub repository name where secrets will be stored | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub personal access token with 'repo' permissions | `string` | n/a | yes |
| <a name="input_oauth_client_id"></a> [oauth\_client\_id](#input\_oauth\_client\_id) | Tailscale WIF client ID (TS\_OAUTH\_CLIENT\_ID) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Comma-separated Tailscale tags assigned to CI runner devices (TS\_TAGS) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->