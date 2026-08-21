include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment
  region      = include.root.locals.aws_region

  vpc_endpoints_hcl     = find_in_parent_folders("vpc_endpoints.hcl")
  endpoint_host_offsets = read_terragrunt_config(local.vpc_endpoints_hcl).locals.endpoint_host_offsets

  # route53's VPC endpoint service is published as the global "com.amazonaws.route53"
  # (no region segment), unlike every other service here. The module requires
  # service_endpoint to be set explicitly whenever region is (per its own variable
  # description), so compute it ourselves for every service instead of relying on its
  # data source lookup.
  service_endpoints = merge(
    {
      for svc in keys(local.endpoint_host_offsets) : svc =>
      svc == "route53" ? "com.amazonaws.route53" : "com.amazonaws.${local.region}.${svc}"
    },
    { s3 = "com.amazonaws.${local.region}.s3" }
  )
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws//modules/vpc-endpoints?version=${values.version}"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                  = "mock-vpc-id"
    private_subnets         = ["mock-subnet-1", "mock-subnet-2", "mock-subnet-3"]
    private_route_table_ids = ["mock-rt-1", "mock-rt-2", "mock-rt-3"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "endpoint_cidrs" {
  config_path = "../endpoint_cidrs"
  mock_outputs = {
    endpoint_ips = {
      for svc in keys(local.endpoint_host_offsets) : svc => [
        { subnet_id = "mock-subnet-1", ipv4 = "10.2.0.10" },
        { subnet_id = "mock-subnet-2", ipv4 = "10.2.32.10" },
        { subnet_id = "mock-subnet-3", ipv4 = "10.2.64.10" },
      ]
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  region = local.region

  endpoints = merge(
    {
      for svc, offset in local.endpoint_host_offsets : svc => {
        service_endpoint      = local.service_endpoints[svc]
        private_dns_enabled   = true
        subnet_ids            = dependency.vpc.outputs.private_subnets
        subnet_configurations = dependency.endpoint_cidrs.outputs.endpoint_ips[svc]
      }
    },
    {
      # Gateway endpoint, route table prefix-list entry, no ENI, no IP to pin. AWS also
      # offers an Interface variant of s3, so service_type must be explicit or the
      # module defaults to Interface.
      s3 = {
        service_endpoint = local.service_endpoints.s3
        service_type     = "Gateway"
        route_table_ids  = dependency.vpc.outputs.private_route_table_ids
      }
    }
  )

  tags = {
    environment = "${local.environment}"
  }
}
