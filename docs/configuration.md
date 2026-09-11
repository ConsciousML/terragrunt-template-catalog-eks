# Configuration

## Authenticate with the AWS CLI
You'll need to authenticate with the AWS CLI to deploy cloud resources with [Terraform](https://developer.hashicorp.com/terraform) (TF).
The EKS stack provisions resources across many AWS services, so `AdministratorAccess` is the convenient choice here.
You can scope down to a narrower policy later by reviewing the [units](../units/README.md) this catalog uses.

### Fast Track (admin)
If you're a root user or admin:
1. create an [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
2. [attach the `AdministratorAccess` policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage-attach-detach.html) to it
3. [create an access key](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) for the user
4. Authenticate with the AWS CLI using the `AWS Access Key ID` and `AWS Secret Access Key` secret key:
```bash
aws configure
```

:::warning
The fast track authentication enables you to get started quickly.
However, long-term credentials are not recommended for production use.
Instead consider following the [security best practices in IAM documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html).
:::

### Organization Member
If you're an organization member, ask your admin to attach the [`AdministratorAccess`](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AdministratorAccess.html) IAM policy to your identity. Then, authenticate to the CLI using the method recommended by your AWS administator. More information in the [AWS CLI authentication documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html).

## Architecture
The catalog contains multiple building blocks that follow a layered architecture where each layer builds upon the previous one:
1. [Terraform module](https://developer.hashicorp.com/terraform/language/modules): a re-usable component that creates cloud resources.
2. [Terragrunt unit](https://docs.terragrunt.com/features/units/): a wrapper over a TF module. It defines a single, deployable piece of infrastructure.
3. [Terragrunt stack](https://docs.terragrunt.com/features/stacks/): a re-usable [DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph) of units.

In other words, a stack orchestrates multiple units that materialize TF modules.
The [`modules/`](../modules/), [`units/`](../units/), and [`stacks/`](../stacks/) directories contain these components respectively.
In the [`pipelines/`](../pipelines/) directory, you'll find all the implemented stacks, also called pipelines.

## Catalog Configuration
These pipelines are modular. They read `.hcl` configuration files that you need to modify:
1. In [`pipelines/github.hcl`](../pipelines/github.hcl), modify the following variables:
```hcl
locals {
  github_owner_catalog      = "<YourGitHubUsernameOrOrgName>"           # Example: ConsciousML
  github_repo_name_catalog  = "<the-repository-name-of-your-fork>"   # Example: eks-forge-catalog
}
```
Where:
- `<the-repository-name-of-your-fork>` should be the name you chose when [you forked the catalog](../../quickstart/installation#fork-the-eks-forge-catalog)
- `<github_owner_catalog>` is the GitHub username or organization name where your fork lives 

2. Change `pipelines/region.hcl` to match your desired AWS region and Availability Zones (AZs):
```hcl
locals {
  region = "us-east-1"
  azs    = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
```
You can also leave it as is if you plan to use `us-east-1`.