# GitHub Actions AWS Bootstrap
Authenticated GitHub Actions with AWS and enables to run Terragrunt in CI/CD.

## Purpose

Run this **once** after creating a new GitHub repository from this template to authenticate GitHub Actions with AWS.

This enables the CI to run properly without managing secrets and AWS credentials manually.

## Quick Start

### Prerequisites
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

### Configuration

Set up `GITHUB_TOKEN` following the [environment variables guide](../../../docs/environment-variables.md#github_token).

In the `terragrunt.stack.hcl`, update the following values in the `stack "aws_gh_actions_auth"` block:

```hcl
values = {
  iam_role_name = "gh-terragrunt-role-catalog"

  # Replace this by a list of fine-grained IAM policies for improved security 
  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  # Restrict to a specific branch for tighter security (e.g. "main")
  # Defaults to "*" which allows all branches
  github_branch = "*"

  # OIDC Provider creation needs to be set to true only for the first repo in this AWS account
  create_oidc_provider = false

  # List of repository names to give read-only access to the CI
  # This is necessary for Terragrunt to pull remote source code from external repositories
  deploy_key_repositories = [
    "repo_name_1",
    ...
    "repo_name_N"
  ]

  # Attribute a secret name for each deploy key. Use the same order as deploy_key_repositories
  deploy_key_secret_names = [
    "DEPLOY_KEY_TG_CATALOG",
    ...
  ]

  deploy_key_title = "Terragrunt Catalog Deploy Key"
  # ... other values can remain as defaults
}
```

**Caution:** 
- The GitHub Actions OIDC provider is a **global AWS account-level resource**.
- It can only be created once per AWS account.
- If you've already run this bootstrap pipeline in another repository using the same AWS account, set `create_oidc_provider = false` to use the existing OIDC provider instead of attempting to create a new one. Otherwise, the deployment will fail with an `EntityAlreadyExists` error.
- Also change the value of `iam_role_name` to avoid conflicts.

### Deploy
From the root directory of this repository, run:
```bash
source .env
cd pipelines/bootstrap/aws_gh_actions_auth/
terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive
```

### Update Your GitHub Actions file
**Optional:** if you haven't changed the deploy key secret names, you can skip this step.

Update your `.github/workflows/ci.yaml` to use the correct deploy key secret names in the setup action:

For single deploy key, update the `deploy-keys` parameter to match the value in `deploy_key_secret_names`:
```yaml
- uses: ./.github/actions/setup
  with:
    deploy-keys: ${{ secrets.YOUR_DEPLOY_KEY_NAME }}
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ${{ secrets.AWS_REGION }}
    # other arguments are unchanged
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
    # other arguments are unchanged
```

### Using the CI
Read the [continuous integration guide](../../../docs/continuous-integration.md#using-the-ci).

## Module Details

This stack instantiates the following Terraform modules to run Terragrunt with GitHub Actions.

### 1. [GitHub OIDC Provider](../../../modules/oidc_provider/README.md)
Creates an [AWS IAM OpenID Connect provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) to declare the external identity provider (GitHub Actions in this case).

**Why**: GitHub Actions will be a known audience to AWS and will validate its token when authentication occurs.

### 2. [IAM Role GitHub Actions](../../../modules/iam_role_github_actions/README.md)
Creates an IAM Role that can only be used by GitHub Actions running under this specific repository.

### 3. [GitHub Actions IAM Policies](../../../modules/iam_policies/README.md)
Assigns policy ARNs to the IAM role from 2.
This enables the necessary permissions for Terragrunt to run in GitHub Actions.

### 4. [GitHub Secrets](../../../modules/github_secrets/README.md)
Stores `AWS_REGION` and `AWS_ROLE_ARN` as GitHub secrets to be retrieved in GitHub Actions workflows.

### 5. [Deploy Key](../../../modules/deploy_key/README.md)
Generates an SSH deploy key for repository access.

Enables Terragrunt to pull code from private repositories during multi-repo deployments.

### 6. [Terraform Docs Deploy Key](../../../modules/deploy_key/README.md)
Generates a separate write-access deploy key used by the `terraform-docs` CI step to commit auto-generated module documentation back to the repository.

## Authentication Flow

1. OIDC Provider establishes GitHub Actions as a trusted identity provider in AWS
2. IAM Role defines who can authenticate (specific GitHub repo/branch) via trust policy
3. IAM Policies define what the role can do once authenticated (creating, modifying and deleting AWS resources through Terragrunt)
4. GitHub Secrets stores the role ARN and region for workflows to reference
5. Deploy Key enables Terragrunt to access private repositories during execution
