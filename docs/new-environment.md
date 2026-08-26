# Create a New Environment

Changes span both `pipelines/network.hcl` and the bootstrap setup. Hard prerequisites for the final EKS deploy: the Tailscale ACL must include the new VPC CIDR before the connector can route traffic, and the public Route53 hosted zone must exist before ACM can validate TLS certificates.

> **Deploying a staging or production environment?** Those live in the live repo. Follow the [live repo new environment guide](https://github.com/ConsciousML/terragrunt-template-live-eks/blob/main/docs/new-environment.md) instead.

The example below adds a `dev-2` environment.

## Prerequisites

Complete the [Getting Started](../README.md#getting-started) guide in full. You need at least one working environment (`dev`) before adding another.

## Steps

### Add the CIDR to the Catalog

Add the new environment to `pipelines/network.hcl`:

```hcl
locals {
  vpc_cidrs = {
    prod           = "10.0.0.0/16"
    staging        = "10.1.0.0/16"
    dev            = "10.2.0.0/16"
    catalog-eks-ci = "10.3.0.0/16"
    dev-2          = "10.4.0.0/16"  # new
  }
}
```

Pick the next available `/16` block. Check `pipelines/network.hcl` for CIDRs already in use.

### Re-run the Tailscale Bootstrap

The Tailscale ACL reads all VPC CIDRs from `network.hcl` automatically. Re-applying the bootstrap picks up the new entry and adds it to `autoApprovers`. See the [Tailscale bootstrap README](../pipelines/bootstrap/tailscale/README.md) for prerequisites and commands.

### Run the DNS Bootstrap

Copy the dev DNS bootstrap directory:

```bash
cp -r pipelines/bootstrap/setup_dns/dev pipelines/bootstrap/setup_dns/dev-2
```

Edit `pipelines/bootstrap/setup_dns/dev-2/environment.hcl`:

```hcl
locals {
  environment = "dev-2"
}
```

Then apply it and delegate the NS records at your registrar. See the [DNS bootstrap README](../pipelines/bootstrap/setup_dns/README.md) for the full deploy and delegation steps.

### Create the Environment Directory

```bash
cp -r pipelines/dev pipelines/dev-2
```

Update `pipelines/dev-2/environment.hcl`:

```hcl
locals {
  environment       = get_env("TG_ENVIRONMENT", "dev-2")
  environment_alias = get_env("TG_ENVIRONMENT_ALIAS", "dev-2")
}
```

If `dev-2` should reuse `dev`'s Helm value overlays instead of getting its own, set `environment_alias`'s default to `"dev"`.

### Deploy the EKS Stack

```bash
source .env
cd pipelines/dev-2/eks/stack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

### Disable the Public EKS Endpoint

The cluster unit's `values` block keeps `endpoint_public_access` set to `true` for this first apply, since ArgoCD, app-of-apps, and the Tailscale Connector (which routes CI into the VPC) don't exist yet on a brand-new cluster.

Once the stack is up, follow the [Disable the Public EKS Endpoint](../README.md#disable-the-public-eks-endpoint) step in the main README, using `pipelines/dev-2` in place of `pipelines/dev`.
