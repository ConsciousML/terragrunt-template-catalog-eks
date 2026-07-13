# Local Development Environment

This directory provides the local development environment for iterating on Terragrunt catalog changes.

## Purpose

This environment is designed for **local development only**.

For production deployments, use the [terragrunt-template-live-eks](https://github.com/ConsciousML/terragrunt-template-live-eks) repository.

## Configuration Files

The dev directory uses the same configuration pattern as the live template:

- [`root.hcl`](../root.hcl): S3 backend and AWS provider inherited by all units
- [`region.hcl`](../region.hcl): AWS region for all resources
- [`dns.hcl`](../dns.hcl): Base domain and subdomain used for Route53 and ACM
- [`network.hcl`](../network.hcl): VPC CIDR blocks
- [`github.hcl`](../github.hcl): GitHub username, catalog repository name, and app-of-apps repository name for module sources
- [`version.hcl`](../version.hcl): Resolves the current git branch used as `?ref=` in all module sources
- [`environment.hcl`](environment.hcl): Environment name (e.g., `dev`) used for resource naming and state isolation
- [`cluster_name.hcl`](cluster_name.hcl): EKS cluster name

## Stack Configuration

Stacks in `pipelines/dev/` reference the catalog using relative paths:

```hcl
unit "vpc" {
  source = "${get_repo_root()}/units/vpc"
  ...
}
```

## Getting Started

### Prerequisites
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

### Deploy a Stack
```bash
cd pipelines/dev/eks/stack

terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

### Destroy a Stack
```bash
cd pipelines/dev/eks/stack

terragrunt run --all destroy --no-stack-generate
```

## Production Setup

For production environments, use [terragrunt-template-live-eks](https://github.com/ConsciousML/terragrunt-template-live-eks) which provides:
- Environment separation (dev/staging/prod)
- Production-ready CI/CD 
- Proper state management across environments