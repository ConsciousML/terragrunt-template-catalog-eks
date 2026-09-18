{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS Service Quotas Bootstrap

In this guide, you'll check whether your AWS account has enough EC2 vCPU headroom for [deployment](/docs/quickstart/deployment/), and request more if it doesn't.

:::danger
If these quotas are already managed elsewhere, skip this guide entirely. If the account already runs other EC2 workloads outside this template, size your request to cover their vCPU usage too, not just this template's.
:::

:::warning
This bootstrap is scoped to the AWS account, not a repo or environment: only run it in your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), and only once per account. The increase is reviewed manually by AWS and can't be undone quickly, so requesting one you don't need risks an unnecessary or conflicting request.
:::

EKS Forge's EC2 usage exceeds a new account's default quotas (5 vCPU for both On-Demand and Spot Standard instances). Without enough headroom, [deployment](/docs/quickstart/deployment/) fails because AWS can't allocate enough instances.

First, check the account's current values for the two quotas this template uses:
```bash
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A # On-Demand Standard
aws service-quotas get-service-quota --service-code ec2 --quota-code L-34B43A08 # Spot Standard
```

If this is your first time running the quickstart and neither warning above applies, continue below with the default values. Otherwise, raise them accordingly, accounting for the vCPU capacity already used by your existing workloads.

:::info
If the account already has enough headroom for both, skip the rest of this guide, no request needed.
:::

Otherwise, update the `locals` block in this bootstrap's [stack file](terragrunt.stack.hcl), in your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), with the values you need:
```hcl
locals {
  ondemand_desired_value = 32 # requested value for L-1216C47A
  spot_desired_value     = 32 # requested value for L-34B43A08
}
```

Now deploy the pipeline. From the root of your catalog fork run the following [Terragrunt commands](/docs/iac):
```bash
source .env
cd pipelines/bootstrap/aws_service_quotas
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Some increases are reviewed manually by AWS and can take time. Track status in the [Service Quotas request history console](https://console.aws.amazon.com/servicequotas/home/requests).

For more information about this bootstrap, read the [reference documentation](/docs/reference/bootstrap/aws_ec2_quotas/).
