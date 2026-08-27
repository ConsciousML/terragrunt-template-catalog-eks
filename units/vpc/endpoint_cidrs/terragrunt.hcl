include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  network_hcl           = find_in_parent_folders("network.hcl")
  network_locals        = read_terragrunt_config(local.network_hcl).locals
  endpoint_host_offsets = local.network_locals.endpoint_host_offsets
  app_param_key_map     = local.network_locals.app_param_key_map
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/vpc_endpoint_cidrs?ref=${values.version}"
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
