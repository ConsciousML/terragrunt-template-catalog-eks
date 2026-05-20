# Examples - Development Environment

This directory provides example configurations for testing Terragrunt stacks during development.

## Purpose

This environment is designed for **development and testing only**.

For production deployments, use the [terragrunt-template-live-eks](https://github.com/ConsciousML/terragrunt-template-live-eks) repository.

## Configuration Files

The examples directory uses the same configuration pattern as the production template:

- `environment.hcl`: Environment name (e.g., "example-2") used for resource naming and state isolation
- `region.hcl`: AWS region for resources
- `root.hcl`" Root configuration that loads variables, configures AWS backend, and sets up providers

These files automatically provide AWS variables (region, environment) to all stacks, eliminating the need to configure them individually.

## Stack Configuration

Stacks in `pipelines/examples/stacks/` reference the catalog using relative paths:

```hcl
unit "vpc" {
  source = "${get_repo_root()}/units/vpc"
  ...
}
```

## Getting Started

### Prerequisites
- Follow the [installation instructions](../README.md#installation)
- Same [prerequisites](../README.md#prerequisites) as in the main `README.md`

### Deploy a Stack
```bash
cd pipelines/examples/stacks/eks

terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive
```

### Destroy a Stack
```bash
cd pipelines/examples/stacks/eks

terragrunt run --all destroy
```

## Production Setup

For production environments, use [terragrunt-template-live-eks](https://github.com/ConsciousML/terragrunt-template-live-eks) which provides:
- Environment separation (dev/staging/prod)
- Production-ready CI/CD 
- Proper state management across environments