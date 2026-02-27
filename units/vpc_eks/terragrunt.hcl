include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  region_hcl    = find_in_parent_folders("region.hcl")
  region_locals = read_terragrunt_config(local.region_hcl).locals
  region        = local.region_locals.region
  azs           = local.region_locals.azs
}

terraform {
  source = "terraform-aws-modules/vpc/aws"
  create_vpc = values.create_vpc

  name = "${values.vpc_name}-${local.environment}"

  cidr = values.cidr
  azs = local.azs

  private_subnets = values.private_subnets
  public_subnets = values.public_subnets

  enable_nat_gateway   = values.enable_nat_gateway
  single_nat_gateway   = values.single_nat_gateway
  one_nat_gateway_per_az = values.one_nat_gateway_per_az
  
  enable_dns_hostnames = values.enable_dns_hostnames
  enable_dns_support   = values.enable_dns_support

  public_subnet_tags = values.public_subnet_tags

  private_subnet_tags = values.private_subnet_tags

  tags = {
    environment = "${local.environment}"
  }
}