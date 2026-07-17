include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/deploy_key/?ref=${values.version}"
}

inputs = {
  github_token       = values.github_token
  github_owner       = include.root.locals.github_username_catalog
  repositories       = values.repositories
  secret_names       = values.secret_names
  current_repository = values.current_repository
  deploy_key_title   = values.deploy_key_title
  read_only          = values.read_only
}