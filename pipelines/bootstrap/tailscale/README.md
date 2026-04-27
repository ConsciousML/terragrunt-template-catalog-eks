# Tailscale Bootstrap

Sets up Tailscale access control policy and OAuth infrastructure so the Tailscale Kubernetes operator can join the cluster and route VPC traffic to your Tailnet.

## Purpose

Run this **once** before deploying the Tailscale operator into any EKS cluster. The ACL policy and OAuth client must exist in Tailscale before the per-cluster units can create subnet routers and configure split DNS.

This bootstrap creates:

| Resource | Purpose |
|----------|---------|
| Tailscale ACL | Defines `tag:k8s-operator` and `tag:k8s` tags, auto-approves the VPC CIDR range, and grants member → VPC accept rules |
| OAuth client | Scoped credentials used by the Tailscale Kubernetes operator to register nodes and manage auth keys |

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
