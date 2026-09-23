{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# AWS Service Quotas Bootstrap

In this guide, you'll check whether your AWS account has enough EC2 vCPU headroom for [deployment](/docs/quickstart/deployment/), and request more if it doesn't.

:::danger
These quotas are account-wide. If they're already managed elsewhere (another team, another IaC repo, AWS Organizations quota templates), skip this guide. If the account already runs other EC2 workloads, size your request to cover their vCPU usage too, as described in the [reference documentation](/docs/reference/bootstrap/aws_ec2_quotas/#sizing-the-request).
:::

:::warning
This guide needs to be performed only once per AWS account, from your [catalog repository fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), before running the [deployment](/docs/quickstart/deployment/).
:::

EKS Forge's EC2 usage exceeds a new account's default quotas (5 vCPU for both On-Demand and Spot Standard instances). Without enough headroom, [deployment](/docs/quickstart/deployment/) fails because AWS can't allocate enough instances.

First, check the account's current values for the two quotas EKS Forge uses:
```bash
aws service-quotas get-service-quota --service-code ec2 --quota-code L-1216C47A # On-Demand Standard
aws service-quotas get-service-quota --service-code ec2 --quota-code L-34B43A08 # Spot Standard
```

If both values are at least `ondemand_desired_value` and `spot_desired_value` in the [stack file](terragrunt.stack.hcl), skip the rest of this guide.

Otherwise, run the following [Terragrunt commands](/docs/iac) from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/aws_service_quotas
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

AWS approves some increases instantly. Others are reviewed manually and can take a day or more, which is normal.

Finally, re-run the check from the first step. Once AWS approves the requests, both values match the ones in the stack file. While AWS reviews them, track their status in the [Service Quotas request history console](https://console.aws.amazon.com/servicequotas/home/requests).

For more information about this bootstrap, read the [reference documentation](/docs/reference/bootstrap/aws_ec2_quotas/).
