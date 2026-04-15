include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/route53_hosted_zone?ref=${values.version}"
}

inputs = {
  name    = values.name
  comment = values.comment
  tags = {
    environment = "${local.environment}"
  }
}
