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

  # root.hcl injects region into every unit's inputs by default. This module also
  # declares its own "region" variable, but for cross-region endpoint overrides: a
  # non-null value disables its service-name data source lookup entirely, breaking
  # service_name resolution for every endpoint here. Override the global default back
  # to null.
  region = null

  endpoints = merge(
    {
      for svc, offset in local.endpoint_host_offsets : svc => {
        service               = svc
        subnet_ids            = dependency.vpc.outputs.private_subnets
        subnet_configurations = dependency.endpoint_cidrs.outputs.endpoint_ips[svc]
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
