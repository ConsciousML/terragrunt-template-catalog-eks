# Local Development Environment

The local development environment for iterating on catalog changes, using the same [stacks](../../stacks/README.md) and [units](../../units/README.md) as production.

This environment is for **local development only**. For production deployments, use the [terragrunt-template-live-eks](https://github.com/ConsciousML/terragrunt-template-live-eks) repository, which adds environment separation (`dev`, `staging`, and `prod`), production CI/CD, and state isolation across environments.

## Configuration Files

The dev directory uses the same configuration pattern as the live template:

- [`root.hcl`](../root.hcl): S3 backend and AWS provider inherited by all units
- [`region.hcl`](../region.hcl): AWS region for all resources
- [`dns.hcl`](../dns.hcl): Base domain and per-app subdomains (ArgoCD, guestbook, Prometheus, Alertmanager, Grafana) used for Route53 and ACM
- [`network.hcl`](../network.hcl): VPC CIDR blocks
- [`github.hcl`](../github.hcl): GitHub username, catalog repository name, and app-of-apps repository name for module sources
- [`version.hcl`](../version.hcl): Resolves the current git branch used as `?ref=` in all module sources
- [`environment.hcl`](environment.hcl): Environment name (e.g., `dev`) used for resource naming and state isolation
- [`cluster_name.hcl`](cluster_name.hcl): EKS cluster name
- [`provider_k8s_base.hcl`](provider_k8s_base.hcl): `aws_eks_cluster` and `aws_eks_cluster_auth` data sources shared by other providers, and skips units when the cluster doesn't exist yet
- [`provider_helm.hcl`](provider_helm.hcl): Helm provider configuration sourced from the EKS cluster output
- [`eks/cluster_name_env.hcl`](eks/cluster_name_env.hcl): composes the full cluster name (`{environment}-{cluster_name}`) from `environment.hcl` and `cluster_name.hcl`
- [`eks/domains.hcl`](eks/domains.hcl): composes per-app private and public domains (ArgoCD, guestbook, Prometheus, Alertmanager, Grafana) from `dns.hcl` and `environment.hcl`

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
Perform the [quickstart](../../README.md#getting-started) up to `Authenticate with AWS` (included).

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