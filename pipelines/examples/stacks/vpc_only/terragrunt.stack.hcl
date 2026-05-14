locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
  vpc_cidrs   = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs
  vpc_cidr    = local.vpc_cidrs[local.environment]

  private_subnets = [cidrsubnet(local.vpc_cidr, 8, 1), cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 8, 3), cidrsubnet(local.vpc_cidr, 8, 4)]
}

unit "vpc" {
  source = "${get_repo_root()}/units/vpc"
  path   = "vpc"

  values = {
    create_vpc = true
    version    = "6.6.0"

    name = "vpc-eks"

    # For production, use at least 3 subnets
    private_subnets = local.private_subnets
    public_subnets  = local.public_subnets

    enable_nat_gateway     = true
    single_nat_gateway     = false
    one_nat_gateway_per_az = true

    enable_dns_hostnames = true
    enable_dns_support   = true

    public_subnet_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = 1
    }
  }
}

unit "route53_hosted_zone_private" {
  source = "${get_repo_root()}/units/eks/route53/hosted_zone_private"
  path   = "eks/route53/hosted_zone_private"

  values = {
    version = local.version
    comment = "Managed by Terraform"
  }
}
