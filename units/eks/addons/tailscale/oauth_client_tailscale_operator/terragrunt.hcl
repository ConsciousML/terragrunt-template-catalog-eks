include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  cluster_hcl       = find_in_parent_folders("cluster_name_env.hcl")
  cluster_name_full = read_terragrunt_config(local.cluster_hcl).locals.cluster_name_full
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/tailscale_oauth_client?ref=${values.version}"
}

inputs = {
  description = local.cluster_name_full
  scopes      = ["devices:core", "auth_keys", "services"]
  tags        = ["tag:k8s-operator"]
}
