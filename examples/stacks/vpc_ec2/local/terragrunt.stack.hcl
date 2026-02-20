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
  source = "${get_repo_root()}/units/vpc"
  path   = "vpc"

  values = {
    version            = local.version
    cidr_block         = "10.0.0.0/16"
    enable_dns_support = "false"
  }
}

unit "subnet" {
  source = "${get_repo_root()}/units/subnet"
  path   = "subnet"

  values = {
    version    = local.version
    cidr_block = "10.0.1.0/24"
    zone       = "eu-west-3a"
  }
}

unit "ec2" {
  source = "${get_repo_root()}/units/ec2"
  path   = "ec2"

  values = {
    version       = local.version
    ami           = "ami-0ef9bcd5dfb57b968"
    instance_type = "t3.micro"
  }
}