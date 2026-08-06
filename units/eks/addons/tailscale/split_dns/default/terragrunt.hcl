include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/tailscale_split_dns?ref=${values.version}"
}

dependency "vpc" {
  config_path = "../../../../../vpc"
  mock_outputs = {
    vpc_cidr_block = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "route53_hosted_zone_private" {
  config_path = "../../../../route53/hosted_zone_private"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  domain      = dependency.route53_hosted_zone_private.outputs.domain_name
  nameservers = [cidrhost(dependency.vpc.outputs.vpc_cidr_block, 2)]
}
