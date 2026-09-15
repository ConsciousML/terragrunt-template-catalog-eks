{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS GitHub Actions Authentication Bootstrap

EKS Forge uses [CI/CD](/docs/ci-cd/) to run code quality checks such as `terragrunt plan` on PR. To be able to do that, you'll authenticate GitHub Actions with AWS.

:::warning
This guide needs to be performed only once per repository fork before running the [deployment](/docs/quickstart/deployment/).

If deploying this bootstrap for an additional repository on the same AWS account or organization, read the [reference documentation](/docs/reference/bootstrap/aws_gh_actions_auth/).
:::

To run Terragrunt in GitHub Actions, this [bootstrap pipeline](/docs/quickstart/bootstrap) creates an IAM [OIDC identity provider and role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) that GitHub Actions assumes at runtime. [OpenID Connect](https://docs.github.com/en/actions/concepts/security/openid-connect) (OIDC) is a protocol that lets AWS trust GitHub as an identity provider, so a workflow run authenticates with a GitHub-issued token instead of stored credentials.

After deploying this pipeline, you'll be able to have a functional CI for your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog) without any manual step.

Before starting, set up `GITHUB_TOKEN` in your `.env` file by following the [environment variables guide](/docs/reference/environment_variable/#github_token).

Now let's deploy the pipeline. From the root of your catalog fork run the following commands:
```bash
source .env
cd pipelines/bootstrap/aws_gh_actions_auth/
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Read the [Infrastructure as Code documentation](/docs/iac/) for a better understanding of Terragrunt.
For more information about this bootstrap, read the [reference documentation](/docs/reference/bootstrap/aws_gh_actions_auth/).
