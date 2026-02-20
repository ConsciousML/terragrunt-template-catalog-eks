include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//modules/oidc_provider?ref=${values.version}"
}

inputs = {
  url             = values.url
  client_id_list  = values.client_id_list
  thumbprint_list = values.thumbprint_list
  create          = values.create
  tags = {
    environment = "${local.environment}"
  }
}
