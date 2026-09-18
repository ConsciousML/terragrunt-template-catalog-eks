{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Tailscale WIF Bootstrap

The [`tailscale_wif` stack](../../stacks/tailscale_wif/), deployed by the [`tailscale/wif` pipeline](../../pipelines/bootstrap/tailscale/wif/), creates a Tailscale [Workload Identity Federation](https://tailscale.com/docs/features/workload-identity-federation) credential scoped to this GitHub repository via OIDC, and stores its client ID and audience as GitHub Actions secrets, so CI authenticates to Tailscale using short-lived tokens instead of a stored OAuth secret.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/tailscale).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `tailscale_wif` | [`units/tailscale/workflow_identity_federation`](../../units/tailscale/workflow_identity_federation/) | [`modules/tailscale_wif`](../../modules/tailscale_wif/) |
| `tailscale_github_secrets` | [`units/tailscale/github_secrets`](../../units/tailscale/github_secrets/) | [`modules/github_secrets`](../../modules/github_secrets/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `issuer` | OIDC issuer URL for the federated identity. | `string` | - | Yes |
| `github_owner` | GitHub organization or user account that owns the repository. Combined with `github_repo_name` to build the OIDC subject claim (`repo:<org>/<repo>:*`) scoping the credential to this repository. | `string` | - | Yes |
| `scopes` | OAuth scopes for auth keys issued via this federated identity. | `set(string)` | `["devices:core", "auth_keys", "dns"]` | No |
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name where `TS_OAUTH_CLIENT_ID`, `TS_AUDIENCE`, and `TS_TAGS` are stored. | `string` | - | Yes |
| `ci_tag` | Tailscale tag assigned to CI runner devices joining via WIF. Must already be a `tagOwner` in the ACL applied by the [`tailscale/acl` pipeline](/docs/reference/bootstrap/tailscale_acl/). | `string` | `"tag:ci"` | No |

## Outputs

| Name | Description |
|------|-------------|
| `client_id` | The WIF OAuth client ID. |
| `audience` | The WIF audience value (`api.tailscale.com/<client_id>`). |
