# GitHub Actions AWS Bootstrap
Enables GitHub Actions to authenticate with AWS and enable to run Terragrunt for CI/CD.

## Purpose

Run this **once** after creating a new GitHub repository from this template to authenticate GitHub Actions with AWS.

This enables the CI to run properly without managing secrets and AWS credentials manually.

## Quick Start

### Prerequisites
- Follow the [installation instructions](../README.md#installation):
- Same [prerequisites](../README.md#prerequisites) as in the main `README.md`

### Configuration
In `bootstrap/` change `region.hcl` to match your desire AWS region.
Update the following values in `terragrunt.stack.hcl`:

```hcl
values = {
  github_username      = "YourGitHubUsername"
  current_repository   = "your-current-repo-name"

  # List of the roles necessary for Terragrunt to run in CI/CD
  policy_arns = [
    "arn:aws:iam::aws:policy/YourFirstPolicyName",
    ...
    "arn:aws:iam::aws:policy/YourLastPolicyName"
  ]

  # OIDC Provider creation - set to true for first repo, false for subsequent repos
  create_oidc_provider = true

  # List of repository names to give read-only access to the CI
  # This is necessary for Terragrunt to pull remote source code from external repositories
  deploy_key_repositories = [
    "repo_name_1",
    ...
    "repo_name_N"
  ]

  # Attribute a secret name for each deploy key. Use the same order as the
  # deploy_key_repositories
  deploy_key_secret_names = [
    "DEPLOY_KEY_1",
    ...
    "DEPLOY_KEY_N
  ]

  deploy_key_title = "Terragrunt Catalog Deploy Key"
  # ... other values can remain as defaults
}
```

**Caution:** The GitHub Actions OIDC provider is a **global AWS account-level resource**. It can only be created once per AWS account. If you've already run this bootstrap pipeline in another repository using the same AWS account, set `create_oidc_provider = false` to use the existing OIDC provider instead of attempting to create a new one. Otherwise, the deployment will fail with an `EntityAlreadyExists` error.

Autenticate with the GitHub CLI:
```bash
gh auth login --scopes "repo,admin:repo_hook"
```

Add a GitHub fine-grained token to your environment variables:
```bash
export TF_VAR_github_token="$(gh auth token)"
```

### Deploy
```bash
cd bootstrap/enable_tg_github_actions/
terragrunt stack generate
terragrunt stack run apply
```

### Update Your GitHub Actions file

Update your `.github/workflows/ci.yaml` to use the correct deploy key secret names in the setup action:

For single deploy key, update the `deploy-keys` parameter to match the value in `deploy_key_secret_names`:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: ${{ secrets.YOUR_DEPLOY_KEY_NAME }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
```

If using multiple deploy keys:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: |
      ${{ secrets.DEPLOY_KEY_SECRET_NAME_1 }}
      ${{ secrets.DEPLOY_KEY_SECRET_NAME_2 }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
```

### Using the CI
Read the [continuous integration guide](../docs/continuous-integration.md#using-the-ci).

## Module Details

This stack instantiates four Terraform modules that work together to run Terragrunt with GitHub Actions.

### 1. [GitHub OIDC Provider](../modules/oidc_provider/README.md)
Creates an [AWS IAM OpenID Connect provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) provider to declare the external identify provider (GitHub Actions in this case).

**Why**: GitHub Actions will be a known audience to AWS and will validates its token when authentication occurs.

### 2. [IAM Role GitHub Actions](../modules/iam_role_github_actions/README.md)
Creates a IAM Role that can only be used by GitHub Actions running under this specific repository.

### 3. [GitHub Actions IAM Policies](../modules/iam_policies/README.md)
Assign policies arns to 2.
This enables the necessary policies for Terragrunt to run in GitHub Actions.

### 3. [GitHub Secrets](../modules/github_secrets/README.md)
Stores `AWS_REGION` and `AWS_ROLE_ARN` as GitHub secrets to be able to be retrieved in GitHub Actions workflows.

### 4. [Deploy Key](../modules/deploy_key/README.md)
Generates SSH deploy key for repository access.

Enables Terragrunt to pull code from private repositories during multi-repo deployments.

# Authentication Flow:

1. OIDC Provider establishes GitHub Actions as a trusted identity provider in AWS
2. IAM Role defines who can authenticate (specific GitHub repo/branch) via trust policy
3. IAM Policies define what the role can do once authenticated (creating, modifying and deleting AWS resources through Terragrunt)
4. GitHub Secrets stores the role ARN and region for workflows to reference
5. Deploy Key enables Terragrunt to access private repositories during execution