include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/iam_role_github_actions?ref=${values.version}"
}

inputs = {
  name             = values.name
  github_username  = values.github_username
  github_repo_name = values.github_repo_name
  github_branch    = values.github_branch
  inline_policies  = values.inline_policies
  tags = {
    environment = "${local.environment}"
  }
}
