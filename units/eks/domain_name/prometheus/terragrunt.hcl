include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/identity/?ref=${values.version}"
}

locals {
  domains_hcl               = find_in_parent_folders("domains.hcl")
  domain_private_prometheus = read_terragrunt_config(local.domains_hcl).locals.domain_private_prometheus
}

inputs = {
  value = local.domain_private_prometheus
}
