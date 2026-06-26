# Terragrunt Template Catalog for EKS

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Release](https://img.shields.io/github/release/ConsciousML/terragrunt-template-catalog-eks.svg?style=flat)]()
[![CI](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml/badge.svg)](https://github.com/ConsciousML/terragrunt-template-catalog-eks/actions/workflows/ci.yaml)
[![PR's Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat)](http://makeapullrequest.com)

A reusable Terragrunt catalog of modules, units, and stacks for building EKS clusters on AWS.

Comes with a production-grade [EKS Cluster](units/eks/README.md), deployable across `dev`, `staging`, and `prod` environments, that supports:

- GitOps via ArgoCD and the App of Apps pattern
- Public traffic routing via ALB and Gateway API
- Automated DNS and TLS termination
- VPN access via Tailscale
- Node autoscaling via Karpenter

## Catalog vs Live Infrastructure

This toolkit uses two template repositories:
- **Catalog repository** (this repo): Defines a collection of reusable IaC building blocks: Terraform/OpenTofu [modules](./modules/README.md), Terragrunt [units](./units/README.md), and [stacks](./stacks/README.md)
- [**Live repository**](https://github.com/ConsciousML/terragrunt-template-live-eks): Uses these building blocks to deploy them in a multi-environment ecosystem with production CI/CD

You're new to Terragrunt best practices? Read [Gruntwork's official production patterns](https://github.com/gruntwork-io/terragrunt-infrastructure-catalog-example) to get the foundations required to use this toolkit.

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

## Getting Started
### Prerequisites
- AWS account with billing enabled
- GitHub account
- `AdministratorAccess` AWS IAM Policy

### Fork the Repository
1. Click on the `Use this template` > `Create a new repository` button.
2. Under `Repository Name`, choose a name for your repository.

### Configuration
In your forked repository, change the following Terragrunt configuration files:
1. In `pipelines/github.hcl`, modify (by replacing `<YourGitHubUsername>`, `<the-repository-name-of-your-fork>`):
```hcl
locals {
  github_username_catalog      = "<YourGitHubUsername>"
  github_repo_name_catalog     = "<the-repository-name-of-your-fork>"
  github_repo_name_app_of_apps = "<your-app-of-apps-repo-name>"
}
```
`<the-repository-name-of-your-fork>` should be the same name you chose in the previous section. `<your-app-of-apps-repo-name>` should match your fork of [argocd-app-of-apps-template](https://github.com/ConsciousML/argocd-app-of-apps-template).

2. Change `pipelines/region.hcl` to match your desired AWS region

3. Set `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET` in your `.env` (see the [environment variables guide](docs/environment-variables.md))

4. Karpenter's NodePool is capped at 10 vCPUs by default and provisions `spot` instances. Raise `spec.limits.cpu` or switch `karpenter.sh/capacity-type` to `on-demand` in the [EKS stack](pipelines/dev/eks/stack/terragrunt.stack.hcl) for production stability.

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
- [prek](https://github.com/j178/prek#installation)
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
- [Setup DNS](pipelines/bootstrap/setup_dns/README.md): creates one public [Route53 hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) per environment, shared by all apps, delegated once at your registrar
- [Tailscale](pipelines/bootstrap/tailscale/README.md): creates [Tailscale](https://tailscale.com/) resources needed to connect with tools exposed internally in your EKS cluster (ArgoCD, etc.)

Also run the following once per AWS account:
```bash
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```
This creates the EC2 Spot service-linked role required for Karpenter to provision spot instances.

### Deploy a Dev EKS Cluster
Deploy the [EKS Cluster Stack](units/eks/README.md):

```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

After around 15 min, your `dev` EKS cluster will be created.

Connect `kubectl` to your EKS cluster by creating a `kubeconfig` (replace `<region-code>` and `<cluster-name>`):
```bash
aws eks update-kubeconfig --region <region-code> --name <cluster-name>
```

By default, you connect to your cluster with:
```bash
aws eks update-kubeconfig --region eu-west-3 --name dev-cluster
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

ArgoCD is only reachable with the Tailscale. Make sure you have completed the [Tailscale prerequisites](pipelines/bootstrap/tailscale/README.md#prerequisites) and have the Tailscale client running before proceeding.

The ArgoCD host is `argocd.private.dev.<base_domain>` (replace `<base_domain>` with the value from `pipelines/dns.hcl`, e.g. `argocd.private.dev.axelmendoza.com`).

**Web UI**: Open `https://argocd.private.dev.<base_domain>` in your browser and log in with username `admin`. Retrieve the password with:
```bash
aws secretsmanager get-secret-value \
  --secret-id dev-argocd-password \
  --query SecretString \
  --output text | jq -r .plaintext
```

**CLI**: Log in directly in one command:
```bash
argocd login argocd.private.dev.<base_domain> \
  --username admin \
  --password $(aws secretsmanager get-secret-value \
    --secret-id dev-argocd-password \
    --query SecretString \
    --output text | jq -r .plaintext)
```

### Access the Guestbook App

Open `https://guestbook.public.dev.<base_domain>` in your browser. No login required.

Apps are deployed using the [App of Apps](https://github.com/ConsciousML/argocd-app-of-apps-template) pattern: a single ArgoCD Application bootstraps all child apps from that repository.

### Destroy the Infrastructure
Finally, cleanup by destroying the infrastructure (cwd in `pipelines/dev/eks/stack`):

```bash
terragrunt run --all destroy --non-interactive --no-stack-generate
```

**Caution**: This workflow is only for development and testing. Use your catalog components in the [live repository](https://github.com/ConsciousML/terragrunt-template-live-eks) for multi-environment IaC, and production CI/CD.

## Development Workflow

1. Create a feature branch
2. Write/modify modules, units, and stacks
3. Test locally in the `pipelines/dev` folder
4. Create a pull request
5. Merge when CI passes

See the [development guide](docs/development.md) for a detailed workflow with a step-by-step example on how to modify this template.

To modify existing applications or deploy new ones, see the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template#readme).

## Continuous Integration (CI)
The CI provides automated code quality checks on every pull request:
1. Create a branch and make changes
2. Open a pull request to trigger code quality checks
3. Merge when all checks pass

Read more in the [CI workflow guide](docs/continuous-integration.md).

### Pre-commit Setup (recommended)
We use a more efficient framework than [pre-commit](https://github.com/pre-commit/pre-commit) called [prek](https://github.com/j178/prek).

Wire hooks automatically into git automatically:
```bash
prek install
```

Run hooks on demande:
```bash
prek run
```

This runs the same checks as CI locally, catching issues before you push.

## License
This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
