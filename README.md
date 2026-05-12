# Terragrunt Template Catalog for AWS

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/ConsciousML/terragrunt-template-catalog-eks.svg?style=flat)]()
[![CI](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml/badge.svg)](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml)
[![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

A Terragrunt Template Catalog for multi-environment Infrastructure as Code (IaC) for EKS

## Catalog and Live Infrastructure

This toolkit uses two template repositories:
- **Catalog repository** (this repo): Defines a collection of reusable IaC building blocks: Terraform/OpenTofu [modules](./modules/README.md), Terragrunt [units](./units/README.md), and [stacks](./stacks/README.md)
- [**Live repository**](https://github.com/ConsciousML/terragrunt-template-live-eks): Uses these building blocks to deploy them in a multi-environment ecosystem with production CI/CD

You're new to Terragrunt best practices? Read [Gruntwork's official production patterns](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) to get the foundations required to use this toolkit.

## What's Inside

The catalog follows a layered architecture where each layer builds upon the previous one:
```
Modules (modules/) → Units (units/) → Examples (pipelines/examples/)
```

- **[Modules](modules/README.md)**: Reusable Terraform modules that declare AWS resources (VPC, databases, compute instances, etc.)
- **[Units](units/README.md)**: Terragrunt wrappers around modules that add configuration and dependencies
- **[Stacks](stacks/README.md)**: Collections of units arranged in dependency graphs for pattern level re-use across repositories
- **[Examples](pipelines/examples/README.md)**: Configurations for testing and development
- **[CI](docs/continuous-integration.md)**: Automated configuration validation, testing (`terratest`) and documatentation (`terraform-docs`).
- **[Bootstrap](pipelines/bootstrap/README.md)**: Contains pipelines that need to be run once per repository fork

## Getting Started
### Prerequisites
- AWS account with billing enabled
- GitHub account
- `AdministratorAccess` AWS IAM permission

### Fork the Repository
Click on the `Use this template` button.

### Configuration
In your forked repository, change the following Terragrunt configuration files:
1. In `pipelines/github.hcl`, modify:
```hcl
locals {
  github_username  = "YourGitHubUsername"
  github_repo_name = "the-repository-name-of-your-fork"
}
```
2. Change `pipelines/region.hcl` to match your desired AWS region
3. Change `pipelines/dns_config.hcl` to match your domain name where you'll use ACM to sign TLS certificates (if you don't have a domain name, you'll need to register one using a domain registrar such a GoDaddy or Namecheap)

### Installation

**Option 1: Use mise (recommended)**

First, `cd` at the root of this repository. 

Next, install mise:
```bash
curl https://mise.run | MISE_VERSION=v2026.4.0 sh
```

Then, install all the tools in the `mise.toml` file:
```bash
mise trust
mise install
```

Finally, run the following to automatically activate mise when starting a shell:
- For zsh: 
```bash
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc && source ~/.zshrc
```
- For bash:
```bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && source ~/.bashrc
```

For more information on how to use mise, read their [getting started guide](https://mise.jdx.dev/getting-started.html).


**Option 2: Install Tools Manually**
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [tflint](https://github.com/terraform-linters/tflint)
- [Python 3.14.3](https://www.python.org/downloads/)
- [Go 1.26](https://go.dev/doc/install)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [GitHub CLI](https://github.com/cli/cli#installation)

See [mise.toml](./mise.toml) for specific versions.

### Authenticate with AWS
Authenticate to the AWS CLI:
```
aws configure
```

For more information, read the [AWS CLI authentication documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### Run the Bootstrap Pipelines
Run the following Terragrunt pipelines once per repository:
- [AWS GitHub Actions Auth](pipelines/bootstrap/aws_gh_actions_auth/README.md): authenticates GitHub Actions with AWS
- [Setup DNS](pipelines/bootstrap/setup_dns/README.md): creates a [Route53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) to sign TLS certificates with ACM
- [Tailscale](pipelines/bootstrap/tailscale/README.md): creates [Tailscale](https://tailscale.com/) resources needed to connect with tools exposed internally in your EKS cluster (ArgoCD, etc.)

### Deploy a Dev EKS Cluster
Deploy a stack that creates a VPC and an EKS cluster:
```bash
source .env
cd pipelines/examples/stacks/eks
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive
```

After around 15 min, your `dev` EKS cluster will be created.

Connect `kubectl` to your EKS cluster by creating a `kubeconfig` (replace `<region-code>` and `<cluster-name>`):
```bash
aws eks update-kubeconfig --region <region-code> --name <cluster-name>
```

Next, verify `kubectl` is connected:
```
kubectl get pods -n kube-system
```

You should see and output similar to:
```text
NAME                           READY   STATUS    RESTARTS   AGE
aws-node-59ld8                 2/2     Running   0          41m
coredns-845b86cddf-pg8hk       1/1     Running   0          40m
eks-pod-identity-agent-9pq6k   1/1     Running   0          41m
...
```

### Log in to ArgoCD

ArgoCD is only reachable with the Tailscale Client running. Make sure you have completed the [Tailscale prerequisites](pipelines/bootstrap/tailscale/README.md#prerequisites) before proceeding.

The ArgoCD host is formed from `pipelines/dns_config.hcl` as `<subdomain>.example.<base_domain>` (replace `<subdomain>` and `<base_domain>` with the values from that file, e.g. `argocd.example.axelmendoza.com`).

**Web UI**: Open `https://<subdomain>.example.<base_domain>` in your browser and log in with username `admin`. Retrieve the password with:
```bash
aws secretsmanager get-secret-value \
  --secret-id example-argocd-password \
  --query SecretString \
  --output text | jq -r .plaintext
```

**CLI**: Log in directly in one command:
```bash
argocd login <subdomain>.example.<base_domain> \
  --username admin \
  --password $(aws secretsmanager get-secret-value \
    --secret-id example-argocd-password \
    --query SecretString \
    --output text | jq -r .plaintext)
```

Finally, cleanup by destroying the infrastructure (cwd in `pipelines/examples/stacks/eks`):

```bash
terragrunt run --all destroy --non-interactive
```

**Caution**: This workflow is only for development and testing. Use your catalog components in the [live repository](https://github.com/ConsciousML/terragrunt-template-live-eks) for multi-environment IaC, and production CI/CD.

## Development Workflow

1. Create a feature branch
2. Write/modify modules, units, and stacks
3. Test locally in the `pipelines/examples/stacks` folder
4. Create a pull request
5. Merge when CI passes

See the [development guide](docs/development.md) for a detailed workflow with a step-by-step example on how to modify this template.

## Continuous Integration (CI)
The CI provides automated checks and testing:
1. Create a branch and make changes
2. Open a pull request to trigger code quality checks
3. Add the `run-terratest` label for infrastructure deploy and testing with Terratest
4. Merge when all checks pass

Read more in the [CI workflow guide](docs/continuous-integration.md).

### Infrastructure Testing

The `run-terratest` label triggers automated infrastructure tests that deploy real AWS resources, validate functionality, and clean up automatically.

See the [testing guide](tests/README.md) for writing custom tests.

### Pre-commit Setup (recommended)
```bash
pre-commit install
```

This runs the same checks as CI locally, catching issues before you push.

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
