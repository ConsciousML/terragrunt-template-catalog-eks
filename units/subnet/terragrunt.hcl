include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-a01106c2"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//modules/subnet?ref=${values.version}"
}

inputs = {
  vpc_id     = dependency.vpc.outputs.vpc_id
  cidr_block = values.cidr_block
  zone       = values.zone
  tags = {
    environment = "${local.environment}"
  }
}