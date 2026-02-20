locals {
  # Sets the reference of the source code to:
  version = coalesce(
    get_env("GITHUB_HEAD_REF", ""), # PR branch name (only set in PRs)
    get_env("GITHUB_REF_NAME", ""), # Branch/tag name
    try(run_cmd("git", "rev-parse", "--abbrev-ref", "HEAD"), ""),
    "main" # fallback
  )
}

stack "vpc_ec2" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-aws//stacks/vpc_ec2?ref=${local.version}"
  path   = "infrastructure"
  values = {
    version            = local.version
    cidr_block_vpc     = "10.0.0.0/16"
    cidr_block_subnet  = "10.0.1.0/24"
    enable_dns_support = "false"
    zone               = "eu-west-3a"
    ec2_ami            = "ami-0ef9bcd5dfb57b968"
    ec2_instance_type  = "t3.micro"
  }
}
