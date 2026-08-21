include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment

  vpc_endpoints_hcl     = find_in_parent_folders("vpc_endpoints.hcl")
  endpoint_host_offsets = read_terragrunt_config(local.vpc_endpoints_hcl).locals.endpoint_host_offsets
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc//modules/vpc-endpoints?version=${values.version}"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                      = "mock-vpc-id"
    private_subnets             = ["mock-subnet-1", "mock-subnet-2", "mock-subnet-3"]
    private_subnets_cidr_blocks = ["10.2.0.0/19", "10.2.32.0/19", "10.2.64.0/19"]
    private_route_table_ids     = ["mock-rt-1", "mock-rt-2", "mock-rt-3"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id

  endpoints = merge(
    {
      for svc, offset in local.endpoint_host_offsets : svc => {
        service    = svc
        subnet_ids = dependency.vpc.outputs.private_subnets
        subnet_configurations = [
          for i, cidr in dependency.vpc.outputs.private_subnets_cidr_blocks : {
            ipv4      = cidrhost(cidr, offset)
            subnet_id = dependency.vpc.outputs.private_subnets[i]
          }
        ]
      }
    },
    {
      # Gateway endpoint, route table prefix-list entry, no ENI, no IP to pin.
      s3 = {
        service         = "s3"
        route_table_ids = dependency.vpc.outputs.private_route_table_ids
      }
    }
  )

  tags = {
    environment = "${local.environment}"
  }
}
