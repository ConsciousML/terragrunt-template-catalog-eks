include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/tailscale_wif?ref=${values.version}"
}

inputs = {
  issuer  = values.issuer
  subject = values.subject
  scopes  = values.scopes
  tags    = values.tags
}
