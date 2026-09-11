# Configuration

## Authenticate with the AWS CLI
You'll need to authenticate with the AWS CLI to deploy cloud resources with [Terraform](https://developer.hashicorp.com/terraform) (TF).
The EKS stack provisions resources across many AWS services, so `AdministratorAccess` is the convenient choice here.
You can scope down to a narrower policy later by reviewing the [units](../units/) this catalog uses.

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
If you're an organization member, ask your admin to attach the [`AdministratorAccess`](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AdministratorAccess.html) IAM policy to your identity. Then, authenticate to the CLI using the method recommended by your AWS administrator. More information in the [AWS CLI authentication documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html).

## Catalog Configuration
The catalog is organized into [modules, units, and stacks](../../concepts/#architecture), assembled into deployable pipelines under [`pipelines/`](../pipelines/).

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

This change points all the `terraform { source = <url>}` to your fork instead of the official EKS Forge catalog.
In other words, you'll be able to modify the modules and units yourself going forward.

2. Change `pipelines/region.hcl` to match your desired AWS region and Availability Zones (AZs):
```hcl
locals {
  region = "us-east-1"
  azs    = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
```
You can also leave it as is if you plan to use `us-east-1`.