locals {
  endpoint_ips = {
    for svc, offset in var.endpoint_host_offsets : svc => [
      for i, cidr in var.private_subnets_cidr_blocks : {
        subnet_id = var.private_subnets[i]
        ipv4      = cidrhost(cidr, offset)
      }
    ]
  }
}

output "endpoint_ips" {
  description = "Pinned ENI IP per subnet, per interface endpoint service"
  value       = local.endpoint_ips
}

output "vpc_endpoint_cidrs" {
  description = "Pinned ENI IPs, re-keyed through app_param_key_map for CiliumNetworkPolicy consumers"
  value = {
    for svc, key in var.app_param_key_map : key => [
      for ip in local.endpoint_ips[svc] : ip.ipv4
    ]
  }
}
