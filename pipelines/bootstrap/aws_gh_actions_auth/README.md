{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS GitHub Actions Authentication Bootstrap

In this guide, you'll authenticate GitHub Actions with AWS, so the [CI/CD](/docs/ci-cd/) of your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog) can run code quality checks (pre-commit hooks, Trivy scans, and `terragrunt plan`) on every PR.

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).
:::

This [bootstrap pipeline](/docs/quickstart/bootstrap) creates an IAM [OIDC identity provider and role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that GitHub Actions assumes at runtime, so workflows authenticate with a short-lived GitHub token instead of stored AWS keys. It also stores the role ARN and the deploy keys Terragrunt needs to pull your catalog as GitHub Actions secrets.

First, set up your `.env` file by following the [prerequisite](/docs/reference/environment_variable/#prerequisite) and [`GITHUB_TOKEN`](/docs/reference/environment_variable/#github_token) sections of the environment variables reference.

Next, run the following from the root directory of [your fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/aws_gh_actions_auth/
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Read the [Infrastructure as Code documentation](/docs/iac) for a high-level overview of Terragrunt.

Then, check that the IAM role exists:
```bash
aws iam get-role --role-name gh-terragrunt-role-catalog --query Role.Arn --output text
```

You should see `arn:aws:iam::<account_id>:role/gh-terragrunt-role-catalog`.

Finally, list the GitHub Actions secrets of your fork:
```bash
gh secret list
```

You should see `AWS_REGION`, `AWS_ROLE_ARN`, `DEPLOY_KEY_TG_CATALOG`, and `TERRAFORM_DOCS_DEPLOY_KEY`. These are the secrets GitHub Actions uses to authenticate with AWS and pull your catalog.

The deploy keys themselves are listed with:
```bash
gh repo deploy-key list
```

You should see `Terragrunt Catalog Deploy Key` and `Terraform Docs Deploy Key`.

For more information about this bootstrap, read the [reference documentation](/docs/reference/bootstrap/aws_gh_actions_auth/).
