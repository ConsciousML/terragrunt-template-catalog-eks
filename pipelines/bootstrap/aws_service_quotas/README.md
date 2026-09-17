{/* This doc is deprecated and does not yet follow Diataxis. Do not base new docs on its style or structure. */}
# AWS Service Quotas Bootstrap

Deploys the [`ec2_quotas`](../../../stacks/ec2_quotas/) stack: requests an increase for the account's EC2 `L-1216C47A` (Running On-Demand Standard instances) and `L-34B43A08` (All Standard Spot Instance Requests) vCPU Service Quotas.

**Warning**: only instantiate this in the catalog repo, not in a live repo. It's scoped to the AWS account, not to a repo or environment. Skip this pipeline if the account already has sufficient quota headroom: running it against an account that already has enough risks an unnecessary or conflicting request.

This template's EC2 usage exceeds AWS's default quotas (5 vCPU for both On-Demand and Spot Standard instances on a new account). Without this pipeline, the EKS stack deploy fails because AWS can't allocate enough EC2 instances. Run this **once per AWS account** to provision headroom before deploying.

Before deciding whether to skip this pipeline, check the account's current values:

```bash
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A # On-Demand Standard
aws service-quotas get-service-quota --service-code ec2 --quota-code L-34B43A08 # Spot Standard
```

For guidance sizing the requested values against your `eks_managed_node_groups` and Karpenter NodePool configuration, see [Increase EC2 Capacity](/docs/compute/increase-ec2-capacity/).

Update the `locals` block in `terragrunt.stack.hcl` in this directory:

```hcl
locals {
  ondemand_desired_value = 32 # requested value for L-1216C47A
  spot_desired_value     = 32 # requested value for L-34B43A08
}
```

From the root directory of this repository, run:

```bash
source .env
cd pipelines/bootstrap/aws_service_quotas
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Some quota increase requests are validated manually by AWS. Check status in the [Service Quotas request history console](https://us-east-1.console.aws.amazon.com/servicequotas/home/requests).

For more information about this bootstrap, read the [`ec2_quotas`](/docs/reference/bootstrap/aws_ec2_quotas/) reference documentation.
