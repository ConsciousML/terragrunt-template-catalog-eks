{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS GitHub Actions Authentication Bootstrap

The [`aws_gh_actions_auth` stack](../../stacks/aws_gh_actions_auth/) provisions the [OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)-based trust between GitHub Actions and AWS, letting CI assume an IAM role and deploy Terragrunt without long-lived AWS keys.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/aws_gh_actions_auth).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `github_oidc_provider` | [`units/github/oidc_provider`](../../units/github/oidc_provider/) | [`modules/oidc_provider`](../../modules/oidc_provider/) |
| `iam_role_github_actions` | [`units/github/iam_role`](../../units/github/iam_role/) | [`modules/iam_role_github_actions`](../../modules/iam_role_github_actions/) |
| `iam_policies` | [`units/github/iam_policies`](../../units/github/iam_policies/) | [`modules/iam_policies`](../../modules/iam_policies/) |
| `github_secrets` | [`units/github/secrets/action`](../../units/github/secrets/action/) | [`modules/github_secrets`](../../modules/github_secrets/) |
| `deploy_key` | [`units/github/deploy_key`](../../units/github/deploy_key/) | [`modules/deploy_key`](../../modules/deploy_key/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `oidc_url` | Issuer URL of the OIDC identity provider (GitHub Actions: `https://token.actions.githubusercontent.com`). | `string` | - | Yes |
| `oidc_client_id_list` | Audiences allowed to request tokens from the OIDC provider (GitHub Actions: `["sts.amazonaws.com"]`). | `list(string)` | - | Yes |
| `oidc_thumbprint_list` | Server certificate thumbprints for the provider. Not needed for GitHub Actions, already in AWS's trusted CA library. | `list(string)` | - | Yes |
| `create_oidc_provider` | Whether to create the GitHub OIDC provider. See [OIDC Provider](#oidc-provider). | `bool` | - | Yes |
| `iam_role_name` | Name of the IAM role GitHub Actions assumes. Must be unique per AWS account when multiple repositories bootstrap into the same account. | `string` | - | Yes |
| `github_owner` | GitHub username or organization name that owns the repository. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name. | `string` | - | Yes |
| `github_branch` | Branch allowed to assume the role. `*` allows all branches. | `string` | - | Yes |
| `inline_policies` | Inline IAM policies (`name`, `policy` JSON) attached directly to the role. | `list(object)` | - | Yes |
| `max_session_duration` | Maximum session duration (seconds) for the assumed role. | `number` | `3600` | No |
| `policy_arns` | IAM policy ARNs attached to the role. | `list(string)` | - | Yes |
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `deploy_key_repositories` | Repositories granted read-only deploy key access, so Terragrunt can pull remote source code from them. | `list(string)` | - | Yes |
| `deploy_key_secret_names` | GitHub Actions secret name for each entry in `deploy_key_repositories`, same order. | `list(string)` | - | Yes |
| `deploy_key_title` | Title given to the created deploy keys. | `string` | `"Terragrunt Deploy Key"` | No |

## OIDC Provider

The [GitHub Actions OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) is a global, AWS account-level resource. Only one can exist per AWS account.

Set `create_oidc_provider = false` when another repository already created it in the same AWS account. Setting it `true` a second time fails with `EntityAlreadyExists`. Give each repository's role a distinct `iam_role_name` to avoid conflicts.

In EKS Forge, use `create_oidc_provider = true` in your [catalog](https://github.com/ConsciousML/terragrunt-template-catalog-eks) fork and `create_oidc_provider = false` and in [live](https://github.com/ConsciousML/terragrunt-template-live-eks) fork.

## GitHub Actions Workflow Setup Action

The `setup` action reads deploy keys from GitHub Actions secrets named by `deploy_key_secret_names`, one `deploy-keys` line per entry, in the same order.

Single deploy key:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: ${{ secrets.YOUR_DEPLOY_KEY_NAME }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
```

Multiple deploy keys:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: |
      ${{ secrets.DEPLOY_KEY_SECRET_NAME_1 }}
      ${{ secrets.DEPLOY_KEY_SECRET_NAME_2 }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
```
