# AWS Service Quotas Bootstrap

Deploys the [`ec2_quotas`](../../../stacks/ec2_quotas/) stack: requests an increase for the account's EC2 `L-1216C47A` (Running On-Demand Standard instances) and `L-34B43A08` (All Standard Spot Instance Requests) vCPU Service Quotas.

**Warning**: only instantiate this in the catalog repo, not in a live repo. It's scoped to the AWS account, not to a repo or environment. Skip this pipeline if the account already has sufficient quota headroom: running it against an account that already has enough risks an unnecessary or conflicting request.

## Purpose

This template's EC2 usage exceeds AWS's default quotas (5 vCPU for both On-Demand and Spot Standard instances on a new account). Without this pipeline, the EKS stack deploy fails because AWS can't allocate enough EC2 instances. Run this **once per AWS account** to provision headroom before deploying.

### Check current quotas

Before deciding whether to skip this pipeline, check the account's current values:

```bash
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A # On-Demand Standard
aws service-quotas get-service-quota --service-code ec2 --quota-code L-34B43A08 # Spot Standard
```

### Where vCPU usage is defined

Both quotas are account-wide, covering every on-demand or spot vCPU consumer across every environment on the account. The default `desired_value` in `terragrunt.stack.hcl` is a starting headroom above the AWS default, not a computed sum. Check current and prospective usage against these files before deciding if the default is enough:

- [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](../../dev/eks/stack/terragrunt.stack.hcl): dev's `eks_managed_node_groups`, `karpenter_node_pool_critical`, and `karpenter_node_pool_elastic` blocks
- [`terragrunt-template-live-eks`'s `live/staging/eks/stack/terragrunt.stack.hcl`](https://github.com/ConsciousML/terragrunt-template-live-eks/blob/main/live/staging/eks/stack/terragrunt.stack.hcl): the same blocks for staging
- [`terragrunt-template-live-eks`'s `live/prod/eks/stack/terragrunt.stack.hcl`](https://github.com/ConsciousML/terragrunt-template-live-eks/blob/main/live/prod/eks/stack/terragrunt.stack.hcl): the same blocks for prod

Each of those blocks carries a comment pointing back to this pipeline: if you change instance types, node counts, capacity-type, or AZ count in any of them, revisit these quotas.

## Deployment

### Configuration

Update the `locals` block in `terragrunt.stack.hcl` in this directory:

```hcl
locals {
  ondemand_desired_value = 32 # requested value for L-1216C47A
  spot_desired_value     = 32 # requested value for L-34B43A08
}
```

### Deploy

From the root directory of this repository, run:

```bash
source .env
cd pipelines/bootstrap/aws_service_quotas
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Quota increase requests are asynchronous. Small increases often auto-approve within minutes, but AWS gives no SLA, and larger or new-account requests can take days. `terragrunt apply` returns once the request is submitted, not once it's approved. Check status with the same `aws service-quotas get-service-quota` commands above.

