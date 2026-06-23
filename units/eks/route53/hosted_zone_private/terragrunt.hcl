include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  domains_hcl = find_in_parent_folders("domains.hcl")
  domain_name = read_terragrunt_config(local.domains_hcl).locals.domain_env
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/route53_hosted_zone?ref=${values.version}"
}

dependency "vpc" {
  config_path = "../../../vpc"
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  create       = true
  private_zone = true
  vpc_id       = dependency.vpc.outputs.vpc_id
  name         = local.domain_name
  comment      = values.comment
  tags = {
    environment = include.root.locals.environment
  }
}
