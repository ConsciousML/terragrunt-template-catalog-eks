<!-- BEGIN_TF_DOCS -->
# GitHub Secrets Module

This module creates GitHub Actions secrets from a map of name-value pairs. Use it to provision any set of secrets in a target repository.

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
| [github_actions_secret.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_owner"></a> [github\_owner](#input\_github\_owner) | GitHub organization or user account that owns the target repository | `string` | n/a | yes |
| <a name="input_github_repo_name"></a> [github\_repo\_name](#input\_github\_repo\_name) | GitHub repository name where secrets will be stored | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub personal access token with 'repo' permissions. Required to create and manage GitHub Actions secrets | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of GitHub Actions secret names to their plaintext values | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_created"></a> [secrets\_created](#output\_secrets\_created) | List of GitHub secrets that were created |
<!-- END_TF_DOCS -->