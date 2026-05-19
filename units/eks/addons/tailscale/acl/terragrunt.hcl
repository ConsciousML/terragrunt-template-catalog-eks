include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/tailscale_acl?ref=${values.version}"
}

inputs = {
  acl                        = values.acl
  overwrite_existing_content = values.overwrite_existing_content
  reset_acl_on_destroy       = values.reset_acl_on_destroy
}
