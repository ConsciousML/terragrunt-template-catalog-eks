include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/tailscale_acl?ref=${values.version}"
}

inputs = {
  acl                        = values.acl
  overwrite_existing_content = values.overwrite_existing_content
  reset_acl_on_destroy       = values.reset_acl_on_destroy
}
