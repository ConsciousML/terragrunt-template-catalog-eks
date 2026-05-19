include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/tailscale_wif?ref=${values.version}"
}

inputs = {
  issuer  = values.issuer
  subject = values.subject
  scopes  = values.scopes
  tags    = values.tags
}
