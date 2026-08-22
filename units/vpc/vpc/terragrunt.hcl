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

  vpc_cidr = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs[local.environment]
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=${values.version}"
}

inputs = {
  create_vpc = values.create_vpc

  name = "${values.name}-${local.environment}"

  cidr = local.vpc_cidr
  azs  = local.azs

  private_subnets = values.private_subnets
  public_subnets  = values.public_subnets

  enable_nat_gateway     = values.enable_nat_gateway
  single_nat_gateway     = values.single_nat_gateway
  one_nat_gateway_per_az = values.one_nat_gateway_per_az

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