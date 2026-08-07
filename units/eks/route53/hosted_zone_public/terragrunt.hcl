include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment

  dns_config_hcl = find_in_parent_folders("dns.hcl")
  base_domain    = read_terragrunt_config(local.dns_config_hcl).locals.base_domain
  domain_name    = "${local.environment}.${local.base_domain}"
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/route53_hosted_zone?ref=${values.version}"
}

inputs = {
  create  = values.create
  name    = local.domain_name
  comment = values.comment
  tags = {
    environment = local.environment
  }
}
