include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  dns_config_hcl = find_in_parent_folders("dns_config.hcl")
  domain_name    = read_terragrunt_config(local.dns_config_hcl).locals.domain_name
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/route53_hosted_zone?ref=${values.version}"
}

inputs = {
  name    = local.domain_name
  comment = values.comment
  tags = {
    environment = "${local.environment}"
  }
}
