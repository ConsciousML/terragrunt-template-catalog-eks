# Tailscale Bootstrap

Sets up Tailscale as a VPN and configures the access control policy, workload identity credentials, and GitHub secrets needed to:

- Allow the Tailscale Connector to expose the private VPC subnets to the Tailnet, making internal cluster resources reachable over VPN
- Access internal cluster tools (ArgoCD, etc.) over the Tailnet without exposing them to the public internet
- Allow CI to authenticate to Tailscale to create the Tailscale resources required to bring up the VPN

## Purpose

Run this **once** before deploying the Tailscale operator into any EKS cluster. The ACL policy and WIF credential must exist in Tailscale before the per-cluster units can create subnet routers and configure split DNS.

This bootstrap creates:

| Resource | Purpose |
|----------|---------|
| Tailscale ACL | Defines `tag:k8s-operator`, `tag:k8s`, and `tag:ci` tags, auto-approves the VPC CIDR range for subnet routing |
| Tailscale WIF | Workload Identity Federation credential for GitHub Actions to authenticate to Tailscale without long-lived secrets |
| GitHub Secrets | Stores the WIF client ID and audience as GitHub secrets for CI workflows |

The Kubernetes operator, subnet router, and split DNS are deployed per-cluster as part of the [EKS stack](../../examples/stacks/eks/).

## Quick Start

### Prerequisites
- Follow the [installation instructions](../../../README.md#installation)
- Same [prerequisites](../../../README.md#prerequisites) as in the main `README.md`

Create an account and login at [https://login.tailscale.com/admin/welcome](https://login.tailscale.com/admin/welcome).

Download and install the [Tailscale client](https://tailscale.com/download).

If you haven't already, copy the example environment file:
```bash
cp .env.example .env
```

Go to [Tailscale Trust Credentials](https://login.tailscale.com/admin/settings/trust-credentials), then:

- Click on `+ Credential`
- Select `OAuth` and click on `Continue`
- Select `Scopes > All Read & Write` (or for a fine-grained token, use write access for DNS, Core, Policy File, OAuth, and Federated keys)
- Click on `Generate credential`

You should see a `Credential Added` window.

Copy both the client ID and client secret and add them to your `.env` file:
```bash
export TAILSCALE_OAUTH_CLIENT_ID=<your_client_id>
export TAILSCALE_OAUTH_CLIENT_SECRET=<your_client_secret>
```

### Configuration

Update the `locals` block in `terragrunt.stack.hcl` to match your repository:

```hcl
locals {
  github_user      = "YourGitHubUsername"
  github_repo_name = "your-repo-name"
}
```

The `vpc_cidr` is read automatically from `vpc.hcl` and used to configure the ACL auto-approver. The `ci_tag` can be left as the default `tag:ci`.

### Deploy

From the root directory of this repository, run:
```bash
source .env
cd pipelines/bootstrap/tailscale
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap
```

## Module Details

This stack instantiates three Terraform modules that work together to authenticate CI to Tailscale without long-lived credentials.

### 1. [Tailscale ACL](../../../modules/tailscale_acl/README.md)
Applies the Tailscale ACL policy to your Tailnet.

Defines three tags:
- `tag:ci`: assigned to GitHub Actions runners that join via WIF
- `tag:k8s-operator`: owned by `tag:ci`, assigned to the Tailscale Kubernetes operator
- `tag:k8s`: owned by `tag:k8s-operator`, assigned to nodes managed by the operator

Auto-approves subnet routes for the VPC CIDR so nodes tagged `tag:k8s-operator` or `tag:k8s` can advertise routes without manual approval in the Tailscale admin panel.

### 2. [Tailscale WIF](../../../modules/tailscale_wif/README.md)
Creates a Tailscale Workload Identity Federation credential scoped to GitHub Actions.

**Why**: WIF allows CI to authenticate to Tailscale using short-lived OIDC tokens issued by GitHub Actions, instead of storing a long-lived OAuth client secret. The credential is bound to a specific GitHub repository via the OIDC subject claim and tagged `tag:ci`, which the ACL policy from 1 grants the right to create auth keys for `tag:k8s-operator`. This is the permission the Tailscale operator needs to register itself when deployed into the cluster.

### 3. [Tailscale GitHub Secrets](../../../modules/tailscale_github_secrets/README.md)
Stores the WIF client ID and audience from 2 as GitHub secrets.

This enables CI workflows to authenticate to Tailscale during pipeline runs using the WIF credential, without any long-lived secrets in the repository.
