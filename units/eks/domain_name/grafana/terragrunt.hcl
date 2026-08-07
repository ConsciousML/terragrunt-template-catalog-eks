include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/identity/?ref=${values.version}"
}

locals {
  domains_hcl            = find_in_parent_folders("domains.hcl")
  domain_private_grafana = read_terragrunt_config(local.domains_hcl).locals.domain_private_grafana
}

inputs = {
  value = local.domain_private_grafana
}
