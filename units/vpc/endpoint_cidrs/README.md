# VPC Endpoint CIDRs

Wraps [`modules/vpc_endpoint_cidrs`](../../../modules/vpc_endpoint_cidrs/), a pure-computation module with no AWS resources. Pins each interface VPC endpoint's ENI IP from the VPC's private subnet CIDRs and the offsets in [`pipelines/network.hcl`](../../../pipelines/network.hcl).

Single source of truth for that `cidrhost()` math: [`../endpoints`](../endpoints/) consumes `endpoint_ips` to build the endpoint resources, and `units/eks/addons/argocd/app_of_apps` consumes `vpc_endpoint_cidrs` to feed `CiliumNetworkPolicy` app params.
