include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_role_github_actions?ref=${values.version}"
}

inputs = {
  name             = "${local.environment}-${values.name}"
  github_owner     = values.github_owner
  github_repo_name = values.github_repo_name
  github_branch    = values.github_branch
  inline_policies  = values.inline_policies
  tags = {
    environment = "${local.environment}"
  }
}
