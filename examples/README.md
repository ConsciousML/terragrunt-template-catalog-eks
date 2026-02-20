# Examples - Development Environment

This directory provides example configurations for testing Terragrunt stacks during development.

## Purpose

This environment is designed for **development and testing only**.

For production deployments, use the [terragrunt-template-live-aws](https://github.com/ConsciousML/terragrunt-template-live-aws) repository.

## Configuration Files

The examples directory uses the same configuration pattern as the production template:

- `environment.hcl`: Environment name (e.g., "example-2") used for resource naming and state isolation
- `region.hcl`: AWS region for resources
- `root.hcl`" Root configuration that loads variables, configures AWS backend, and sets up providers

These files automatically provide AWS variables (region, environment) to all stacks, eliminating the need to configure them individually.

## Stack Configuration

Stacks in `examples/stacks/` reference the catalog using git links with automatic version inference:

```hcl
stack "vpc_db" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-aws//stacks/vpc_ec2?ref=${local.version}"
  # ...
}
```

The `ref` parameter automatically resolves to:
1. PR branch name (in pull requests)
2. Current branch name  
3. Current git branch (local development)
4. "main" (fallback)

This allows testing catalog changes from any branch without manual configuration.

## Getting Started

### Prerequisites
- Follow the [installation instructions](../README.md#installation)
- Same [prerequisites](../README.md#prerequisites) as in the main `README.md`

### Deploy a Stack
```bash
cd examples/stacks/vpc_ec2/local/

terragrunt stack generate
terragrunt stack run apply
```

### Destroy a Stack
```bash
cd examples/stacks/vpc_ec2/local/

terragrunt stack run destroy
```

## Production Setup

For production environments, use [terragrunt-template-live-aws](https://github.com/ConsciousML/terragrunt-template-live-aws) which provides:
- Environment separation (dev/staging/prod)
- Production-ready CI/CD 
- Proper state management across environments