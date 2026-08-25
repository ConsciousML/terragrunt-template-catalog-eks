# VPC Endpoints

Wraps the [terraform-aws-modules/vpc//modules/vpc-endpoints](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest/submodules/vpc-endpoints) submodule to provision VPC endpoints for AWS APIs reachable from the cluster's private subnets. Keeps that traffic off the NAT gateway.

Interface endpoints (`secretsmanager`, `route53`, `ecr.api`, `ecr.dkr`, `ec2`, `sts`, `elasticloadbalancing`, `sqs`) each get a fixed `/32` IP pinned on their ENI, so a `CiliumNetworkPolicy` can scope its egress rule to that single address instead of `toEntities: world`. `s3` is a gateway endpoint (route table prefix-list entry, no ENI), so it has no IP to pin.

## Adding an Interface Endpoint

Add an entry to `local.endpoint_host_offsets` in [`pipelines/network.hcl`](../../../pipelines/network.hcl), with an offset unused by any other entry. That offset is read by both this unit and [`../endpoint_cidrs`](../endpoint_cidrs/), which is what actually computes the pinned IP. That's enough to get the endpoint and its pinned IP created.

If a `CiliumNetworkPolicy` should migrate off `toEntities: world` to use that IP, also add the service to `local.app_param_key_map` in the same file, under the consumer-side key its CNP expects, then thread `dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs` into the consuming app's `appParams` entry (see `units/eks/addons/argocd/app_of_apps/terragrunt.hcl`) per [`docs/app-of-apps-integration.md`](../../../docs/app-of-apps-integration.md). A service left out of `app_param_key_map` (like `ecr.dkr`, kept only for NAT cost savings) still gets an endpoint and a pinned IP, it's just not exposed to any CNP.
