include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//modules/vpc?ref=${values.version}"
}


inputs = {
  cidr_block         = values.cidr_block
  region             = local.region
  enable_dns_support = values.enable_dns_support
  tags = {
    environment = "${local.environment}"
  }
}