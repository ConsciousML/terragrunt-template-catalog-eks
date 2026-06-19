include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment

  dns_config_hcl   = find_in_parent_folders("dns.hcl")
  base_domain      = read_terragrunt_config(local.dns_config_hcl).locals.base_domain
  subdomain_argocd = read_terragrunt_config(local.dns_config_hcl).locals.subdomain_argocd
  domain_name      = "${local.subdomain_argocd}.${local.environment}.${local.base_domain}"
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/route53_hosted_zone?ref=${values.version}"
}

dependency "vpc" {
  config_path = "../../../../vpc"
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
    environment = local.environment
  }
}
