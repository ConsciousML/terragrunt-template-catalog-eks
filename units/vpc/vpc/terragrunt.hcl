include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment

  region_hcl    = find_in_parent_folders("region.hcl")
  region_locals = read_terragrunt_config(local.region_hcl).locals
  region        = local.region_locals.region
  azs           = local.region_locals.azs

  network_hcl = find_in_parent_folders("network.hcl")
  vpc_cidr    = read_terragrunt_config(local.network_hcl).locals.vpc_cidrs[local.environment]

  vpc_hcl       = find_in_parent_folders("vpc.hcl")
  vpc_full_name = read_terragrunt_config(local.vpc_hcl).locals.vpc_full_name
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=${values.version}"
}

inputs = {
  create_vpc = values.create_vpc

  name = local.vpc_full_name

  cidr = local.vpc_cidr
  azs  = local.azs

  private_subnets = values.private_subnets
  public_subnets  = values.public_subnets

  enable_nat_gateway     = values.enable_nat_gateway
  single_nat_gateway     = try(values.single_nat_gateway, false)
  one_nat_gateway_per_az = try(values.one_nat_gateway_per_az, false)

  enable_dns_hostnames = values.enable_dns_hostnames
  enable_dns_support   = values.enable_dns_support

  public_subnet_tags = values.public_subnet_tags

  private_subnet_tags = values.private_subnet_tags

  enable_flow_log                                 = values.enable_flow_log
  create_flow_log_cloudwatch_log_group            = values.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role             = values.create_flow_log_cloudwatch_iam_role
  flow_log_traffic_type                           = values.flow_log_traffic_type
  flow_log_max_aggregation_interval               = values.flow_log_max_aggregation_interval
  flow_log_cloudwatch_log_group_class             = values.flow_log_cloudwatch_log_group_class
  flow_log_cloudwatch_log_group_retention_in_days = values.flow_log_cloudwatch_log_group_retention_in_days

  tags = {
    environment = "${local.environment}"
  }
}