include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  cluster_config_hcl = find_in_parent_folders("cluster_config.hcl")
  cluster_name       = read_terragrunt_config(local.cluster_config_hcl).locals.cluster_name
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/tailscale_oauth_client?ref=${values.version}"
}

inputs = {
  description = "${local.environment}-${local.cluster_name}"
  scopes      = ["devices:core", "auth_keys:write", "services:write"]
  tags        = ["tag:k8s-operator"]
}
