# VPC

Wraps the [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) module to provision the VPC that hosts the EKS cluster. For the full list of AWS networking requirements see the [EKS VPC and subnet requirements](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html).

## Constraints

The following inputs are required by EKS and must not be removed:

- `enable_dns_hostnames` and `enable_dns_support` must be `true`. EKS node registration fails without them
- Public subnets must carry `kubernetes.io/role/elb = 1` and private subnets `kubernetes.io/role/internal-elb = 1`. The AWS Load Balancer Controller uses these tags to discover subnets. Missing tags cause load balancer provisioning to fail silently
- A NAT gateway on private subnets is required for traffic with no VPC endpoint (e.g. Tailscale). Most AWS-API traffic (ECR, EC2, STS, ...) instead routes through [`../endpoints`](../endpoints/) and stays off the NAT gateway
- Subnets must span at least two Availability Zones and each have at least 16 available IP addresses
- The VPC CIDR must not overlap with other VPCs connected via Transit Gateway or VPC peering. CIDR conflicts cause unpredictable routing failures
