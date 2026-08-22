include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  vpc_endpoints_hcl     = find_in_parent_folders("vpc_endpoints.hcl")
  endpoint_host_offsets = read_terragrunt_config(local.vpc_endpoints_hcl).locals.endpoint_host_offsets
  app_param_key_map     = read_terragrunt_config(local.vpc_endpoints_hcl).locals.app_param_key_map
}

terraform {
  source = "${get_repo_root()}/modules/vpc_endpoint_cidrs"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnets             = ["mock-subnet-1", "mock-subnet-2", "mock-subnet-3"]
    private_subnets_cidr_blocks = ["10.2.0.0/19", "10.2.32.0/19", "10.2.64.0/19"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  private_subnets             = dependency.vpc.outputs.private_subnets
  private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks

  endpoint_host_offsets = local.endpoint_host_offsets
  app_param_key_map     = local.app_param_key_map
}
