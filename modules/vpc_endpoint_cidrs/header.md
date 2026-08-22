# VPC Endpoint CIDRs

Computes the pinned ENI IP for each interface VPC endpoint from a private subnet CIDR and a per-service host offset. Pure computation, no resources: single source of truth for the `cidrhost()` math shared by `units/vpc/endpoints` (which needs the IP alongside its subnet ID to build the endpoint) and `units/eks/addons/argocd/app_of_apps` (which only needs the plain IP list for a `CiliumNetworkPolicy`'s `vpcEndpointCidrs` app params).
