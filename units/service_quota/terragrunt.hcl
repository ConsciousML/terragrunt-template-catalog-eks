include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/service_quota?ref=${values.version}"
}

inputs = {
  service_code  = values.service_code
  quota_code    = values.quota_code
  desired_value = values.desired_value
}
