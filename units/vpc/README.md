# VPC

Provisions the VPC that hosts the EKS cluster and the AWS-service reachability that keeps cluster traffic off the NAT gateway.

## What's Inside

- **[vpc](vpc/)**: Wraps [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) to create the VPC, subnets, and NAT gateway
- **[endpoint_cidrs](endpoint_cidrs/)**: Pure computation, no AWS resources. Pins each interface VPC endpoint's ENI IP from a private subnet CIDR and a per-service host offset, single source of truth for both `endpoints` and consumers in `argocd-app-of-apps-template`
- **[endpoints](endpoints/)**: Wraps [terraform-aws-modules/vpc//modules/vpc-endpoints](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest/submodules/vpc-endpoints) to provision the actual VPC endpoints, using the pinned IPs from `endpoint_cidrs`
