include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_password/?ref=${values.version}"
}

inputs = {
  secret_name             = "${include.root.locals.environment}-grafana-password"
  length                  = values.length
  recovery_window_in_days = values.recovery_window_in_days
  tags                    = values.tags
}
