# GitHub

Provisions the AWS and GitHub resources needed for GitHub Actions to authenticate with AWS via OIDC and access private repositories.

## Concepts

- [OpenID Connect (OIDC) in GitHub Actions](https://docs.github.com/en/actions/concepts/security/openid-connect)
- [AWS IAM OIDC identity providers](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [GitHub Deploy Keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys)

## What's Inside

- **[oidc_provider](oidc_provider/)**: Creates an [AWS IAM OpenID Connect provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that declares GitHub Actions as a trusted external identity provider. Global per AWS account (set `create = false` when a second repository shares the same account)
- **[iam_role](iam_role/)**: Creates an IAM role whose trust policy is scoped to a specific GitHub repository and branch via the OIDC provider. Its `role_arn` and `role_name` outputs flow into `secrets/action` and `iam_policies`
- **[iam_policies](iam_policies/)**: Attaches managed IAM policy ARNs to the role from `iam_role`, granting the permissions Terragrunt needs to run in CI
- **[secrets/action](secrets/action/)**: Stores `AWS_REGION` and `AWS_ROLE_ARN` as GitHub Actions secrets so workflows can assume the role without hardcoded credentials
- **[secrets/eks_local_admin](secrets/eks_local_admin/)**: Stores `EKS_LOCAL_ADMIN_ARN` as a GitHub Actions secret, derived from the current AWS caller identity. The [CD workflow](https://github.com/ConsciousML/terragrunt-template-live-eks/blob/main/.github/workflows/cd.yaml) reads it via `get_env` and injects it into the cluster `access_entries` (see [prod EKS stack](https://github.com/ConsciousML/terragrunt-template-live-eks/blob/main/live/prod/eks/terragrunt.stack.hcl)), so the local admin retains kubectl access after CI deploys the cluster
- **[deploy_key](deploy_key/)**: Generates SSH deploy keys and registers them on target repositories, enabling Terragrunt to pull code from private repositories during CI. Instantiated twice in the bootstrap stack: once read-only (remote sources), once with write access (terraform-docs commits)

## Integration

- **[`pipelines/bootstrap/aws_gh_actions_auth`](../../pipelines/bootstrap/aws_gh_actions_auth/)**: orchestrates all units in this group as a one-time bootstrap stack. Run it once per repository before enabling CI
- **GitHub Actions workflows**: consume the secrets and deploy keys provisioned by this group to authenticate with AWS and access private repositories
