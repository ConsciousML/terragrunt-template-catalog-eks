# Terragrunt Template Catalog for AWS

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/ConsciousML/terragrunt-template-catalog-eks.svg?style=flat)]()
[![CI](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml/badge.svg)](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml)
[![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

A Terragrunt Template Catalog for EKS production Infrastructure as Code (IaC)

## Catalog vs Live Infrastructure

This is a **catalog repository**, a collection of reusable IaC components.

This toolkit uses two template repositories:
- **This repository** (catalog): Build a collection of reusable [modules](./modules), [units](./units/), and [stacks](./stacks/)
- **Live repository**: Reference these components your the [infrastructure-live repository](https://github.com/ConsciousML/terragrunt-template-live-eks) to deploy them in a multi-environment ecosystem with production CI/CD

You're new to Terragrunt best practices? Read [Gruntwork's official production patterns](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) to get the foundations required to use this extended repository.

## What's Inside

The catalog follows a layered architecture where each layer builds upon the previous one:

```
Modules (modules/) → Units (units/) → Stacks (stacks/) → Examples (pipelines/examples/)
```

- **[Modules](modules/README.md)**: Reusable Terraform modules that declare AWS resources (VPC, databases, compute instances, etc.)
- **[Units](units/README.md)**: Terragrunt wrappers around modules that add configuration and dependencies
- **[Stacks](stacks/README.md)**: Collections of units arranged in dependency graphs for pattern level re-use
- **[Examples](pipelines/examples/README.md)**: Simple configuration for testing and development
- **[Bootstrap](pipelines/bootstrap/)**: Contains pipelines that need to be run once per repository fork for authenticating GitHub Actions with AWS and creating a [Route 53](https://aws.amazon.com/route53/) [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) to sign TLS certificates with [AWS ACM](https://aws.amazon.com/certificate-manager/)
- **[CI](docs/continuous-integration.md)**: Automated configuration validation, testing (`terratest`) and documatentation (`terraform-docs`).

## Getting Started
### Prerequisites
- AWS account with billing enabled
- GitHub account
- AWS IAM permissions to manage IAM roles, VPC resources, EKS resources, compute resources and S3 (see `policy_arns` in the [bootstrap stack](pipelines/bootstrap/enable_tg_github_actions/terragrunt.stack.hcl) for a list of the specific IAM policies)

### Fork the Repository
First, you'll need to fork this repository and make a few changes:
1. Click on `Use this template` to create your own repository
2. Use your IDE of choice to replace every occurrence of `github.com/ConsciousML/terragrunt-template-catalog-eks` and `git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git` by your GitHub repo URL following the same format
3. Change `pipelines/region.hcl` to match your desired AWS region
4. Change `pipelines/dns_config.hcl` to match your domain name where you'll use ACM to sign TLS certificates (if you don't have a domain name, you'll need to register one using a domain registrar such a GoDaddy or Namecheap)

**Warning**: If you skip step 2, the TG source links will still point to the original repository (on `github.com/ConsciousML/`).

### Installation

**Option 1: Use mise (recommended)**

First, `cd` at the root of this repository. 

Next, install mise:
```bash
curl https://mise.run | MISE_VERSION=v2026.4.0 sh
```

Then, install all the tools in the `mise.toml` file:
```bash
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
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))
- [Go](https://go.dev/doc/install)
- [Python 3.14.3](https://www.python.org/downloads/)
- [tflint](https://github.com/terraform-linters/tflint)
- [GitHub CLI](https://github.com/cli/cli#installation)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Go 1.26](https://go.dev/doc/install)

See [mise.toml](./mise.toml) for specific versions.

### Authenticate with AWS
Authenticate to the AWS CLI:
```
aws configure
```

For more information, read the [AWS CLI authentication documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### Run the Bootstrap Pipelines
Follow the [enable Terragrunt in GitHub Actions](pipelines/bootstrap/enable_tg_github_actions/README.md) and [Setup DNS](pipelines/bootstrap/setup_dns/README.md) documentation to authenticate CI/CD with AWS and to setup your hosted zone to sign TLS certificates with ACM



### Deploy a Dev EKS Cluster

Deploy a stack that creates a VPC and an EKS cluster:

```bash
cd pipelines/examples/stacks/eks
terragrunt stack generate
terragrunt stack run apply --backend-bootstrap --non-interactive
```

Go into the AWS console and check that your resources have been created.

After around 15 min, your `dev` EKS cluster will be created.

To connect `kubectl` to your EKS cluster, create a `kubeconfig` file by running the following and replacing `<region-code>` and `<cluster-name>`:
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
aws-node-5bvc4                 2/2     Running   0          41m
coredns-845b86cddf-pg8hk       1/1     Running   0          40m
coredns-845b86cddf-vngdb       1/1     Running   0          40m
eks-pod-identity-agent-9pq6k   1/1     Running   0          41m
eks-pod-identity-agent-fzfk9   1/1     Running   0          41m
kube-proxy-khhsj               1/1     Running   0          40m
kube-proxy-pvh7h               1/1     Running   0          40m
```

Finally, cleanup by destroying the infrastructure (cwd in `pipelines/examples/stacks/eks`):

```bash
terragrunt stack generate
terragrunt stack run destroy --non-interactive
```

**Caution**: This workflow is for development and testing. Use your catalog components in the [infrastructure-live repository](https://github.com/ConsciousML/terragrunt-template-live-eks) for multi-environment IaC, and production CI/CD.

## Development Workflow

1. Create a feature branch
2. Write/modify modules, units, and stacks
3. Test locally using examples
4. Create pull request
5. Merge when CI passes

See the [development guide](docs/development.md) for a detailed workflow with a step-by-step example on how to modify this template.

## Continuous Integration (CI)

After creating your repository from this template, run the [bootstrap process](pipelines/bootstrap/enable_tg_github_actions/README.md) once to configure GitHub Actions authentication with AWS.

The CI provides automated checks and testing:
1. Create a branch and make changes
2. Open a pull request to trigger code quality checks
3. Add the `run-terratest` label for full infrastructure testing
4. Merge when all checks pass

Read more in our [CI workflow guide](docs/continuous-integration.md).

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
