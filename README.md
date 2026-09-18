# Terragrunt Template Catalog for EKS

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/ConsciousML/terragrunt-template-catalog-eks.svg?style=flat)]()
[![CI](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml/badge.svg)](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml)
[![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

A reusable Terragrunt catalog of modules, units, and stacks for building EKS clusters on AWS.

Comes with a production-grade [EKS Cluster](units/eks/README.md), deployable across `dev`, `staging`, and `prod` environments, that supports:

- Persistent storage via EBS-backed `PersistentVolumeClaim`s
- Cluster and workload metrics via Prometheus, Alertmanager, and Grafana
- Workload resource-sizing recommendations via the VPA recommender and Goldilocks
- Log aggregation via Loki
- Public and private traffic routing via ALB and Gateway API
- Automated DNS and TLS termination
- Secrets synced from AWS Secrets Manager
- GitOps via ArgoCD and the App of Apps pattern
- VPN access via Tailscale
- Node autoscaling via Karpenter
- Pod-to-pod network flow visibility via Cilium and Hubble

## Catalog vs Live Infrastructure

This toolkit uses two template repositories:
- **Catalog repository** (this repo): Defines a collection of reusable IaC building blocks: Terraform and OpenTofu [modules](./modules/README.md), Terragrunt [units](./units/README.md), and [stacks](./stacks/README.md)
- [**Live repository**](https://github.com/ConsciousML/terragrunt-template-live-eks): Uses these building blocks to deploy them in a multi-environment ecosystem with production CI/CD

New to Terragrunt best practices? Read [Gruntwork's official production patterns](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) for the foundations this toolkit assumes.

## What's Inside

This catalog contains multiple building blocks that follow a layered architecture where each layer builds upon the previous one:
```
Modules (modules/) → Units (units/) → Dev (pipelines/dev/)
```

Here are the major components of the repository:
- **[EKS Cluster Stack](units/eks/README.md)**: the main contribution of this catalog, a production-grade EKS setup with GitOps, automated DNS, TLS, and VPN access
- **[Modules](modules/README.md)**: Reusable Terraform modules that declare AWS resources (VPC, databases, compute instances, etc.)
- **[Units](units/README.md)**: Terragrunt wrappers around modules that add configuration and dependencies
- **[Stacks](stacks/README.md)**: Collections of units arranged in dependency graphs for pattern level re-use across repositories
- **[Dev](pipelines/dev/README.md)**: Local development environment for iterating on catalog changes
- **[CI](docs/continuous-integration.md)**: Automated configuration validation and documentation (`terraform-docs`).
- **[Bootstrap](pipelines/bootstrap/README.md)**: Contains pipelines that need to be run once per repository fork

## Quickstart
Read the [Quickstart documentation](https://eks-forge.readthedocs.io/latest/docs/quickstart/).

## Development Workflow

1. Create a feature branch
2. Write/modify modules, units, and stacks
3. Test locally in the `pipelines/dev` folder
4. Create a pull request
5. Merge when CI passes

See the [development guide](docs/development.md) for a detailed workflow with a step-by-step example on how to modify this template.

To modify existing applications or deploy new ones, see the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template#readme). For the catalog-side Terragrunt plumbing that threads AWS-sourced values (IAM roles, Secrets Manager secrets, ...) into those apps, see the [App of Apps integration guide](docs/app-of-apps-integration.md).

## Reproducibility
Provider lock files (`.terraform.lock.hcl`) must be committed per unit for stacks to be reproducible.

Read the [reproducibility guide](docs/reproducibility.md) for what to do and why.

## Continuous Integration (CI)
The CI provides automated code quality checks on every pull request:
1. Create a branch and make changes
2. Open a pull request to trigger code quality checks
3. Merge when all checks pass

Read more in the [CI workflow guide](docs/continuous-integration.md).

### Pre-commit Setup (recommended)
We use a more efficient framework than [pre-commit](https://github.com/pre-commit/pre-commit) called [prek](https://github.com/j178/prek).

Wire hooks into git automatically:
```bash
prek install
```

Run hooks on demand:
```bash
prek run
```

This runs the same checks as CI locally, catching issues before you push.

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
