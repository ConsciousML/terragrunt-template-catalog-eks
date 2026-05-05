include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/argocd_password/?ref=${values.version}"
}

inputs = {
  secret_name = "${include.root.locals.environment}-argocd-password"
  length      = values.length
  tags        = values.tags
}
