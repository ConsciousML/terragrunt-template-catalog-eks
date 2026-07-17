# Tailscale Bootstrap

Sets up Tailscale as a VPN and configures the access control policy, workload identity credentials, and GitHub secrets needed to:

- Allow the Tailscale Connector to expose the private VPC subnets to the Tailnet, making internal cluster resources reachable over VPN
- Access internal cluster tools (ArgoCD, etc.) over the Tailnet without exposing them to the public internet
- Allow CI to authenticate to Tailscale to create the Tailscale resources required to bring up the VPN

## Purpose

Run this **once** before deploying the Tailscale operator into any EKS cluster. The ACL policy and WIF credential must exist in Tailscale before the per-cluster units can create subnet routers and configure split DNS.

## Quick Start

### Prerequisites
Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

Create an account and login at [https://login.tailscale.com/admin/welcome](https://login.tailscale.com/admin/welcome).

Download and install the [Tailscale client](https://tailscale.com/download).

### Configuration
Set up `GITHUB_TOKEN`, `TAILSCALE_OAUTH_CLIENT_ID`, and `TAILSCALE_OAUTH_CLIENT_SECRET` following the [environment variables guide](../../../docs/environment-variables.md).

All environment VPC CIDRs are read automatically from `network.hcl` and used to build the ACL `autoApprovers` dynamically. The `ci_tag` can be left as the default `tag:ci`.

### Deploy

The ACL must exist before the WIF credential, since the WIF's OAuth client is scoped to a tag (`tag:ci`) that only the ACL defines. Deploy the two in order, from the root directory of this repository:

```bash
source .env
cd pipelines/bootstrap/tailscale/acl
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

```bash
cd ../wif
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

## Module Details

See the [`units/tailscale`](../../../units/tailscale/README.md) and [`units/eks/addons/tailscale`](../../../units/eks/addons/tailscale/README.md) group READMEs for what each unit provisions and how they compose.
