locals {
  # Sets the reference of the source code to:
  version = coalesce(
    get_env("GITHUB_HEAD_REF", ""), # PR branch name (only set in PRs)
    get_env("GITHUB_REF_NAME", ""), # Branch/tag name
    try(run_cmd("git", "rev-parse", "--abbrev-ref", "HEAD"), ""),
    "main" # fallback
  )
}

unit "vpc" {
  source = "${get_repo_root()}/units/vpc_eks"
  path = "vpc"

  values = {
    create_vpc = true
    version = "6.6.0"

    name = "vpc-eks"

    cidr = "10.0.0.0/16"

    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

    enable_nat_gateway   = true
    single_nat_gateway   = false
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