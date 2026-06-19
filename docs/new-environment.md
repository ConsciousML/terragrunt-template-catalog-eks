# Create a New Environment

Changes span both `pipelines/network.hcl` and the bootstrap setup. Two steps are hard prerequisites for the final EKS deploy: the Tailscale ACL must include the new VPC CIDR before the connector can route traffic, and the public Route53 hosted zone must exist before ACM can validate TLS certificates.

> **Deploying a staging or production environment?** Those live in the live repo. Follow the [live repo new environment guide](https://github.com/ConsciousML/terragrunt-template-live-eks/blob/main/docs/new-environment.md) instead.

The example below adds a `dev-2` environment.

## Prerequisites

Complete the [Getting Started](../README.md#getting-started) guide in full. You need at least one working environment (`dev`) before adding another.

## Steps

### 1. Add the CIDR to the catalog

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

### 2. Re-run the Tailscale bootstrap

The Tailscale ACL reads all VPC CIDRs from `network.hcl` automatically. Re-applying the bootstrap picks up the new entry and adds it to `autoApprovers`. See the [Tailscale bootstrap README](../pipelines/bootstrap/tailscale/README.md) for prerequisites and commands.

```bash
source .env
cd pipelines/bootstrap/tailscale
terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

### 3. Run the DNS bootstrap

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

### 4. Create the environment directory

```bash
cp -r pipelines/dev pipelines/dev-2
```

Update `pipelines/dev-2/environment.hcl`:

```hcl
locals {
  environment = get_env("TG_ENVIRONMENT", "dev-2")
}
```

### 5. Deploy the EKS stack

```bash
source .env
cd pipelines/dev-2/eks
terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```
