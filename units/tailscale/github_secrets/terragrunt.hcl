include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_secrets?ref=${values.version}"
}

dependency "tailscale_wif" {
  config_path = "../workflow_identity_federation"
  mock_outputs = {
    client_id = "mock-client-id"
    audience  = "api.tailscale.com/mock-client-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  github_token     = values.github_token
  github_owner     = include.root.locals.github_username_catalog
  github_repo_name = values.github_repo_name
  secrets = {
    TS_OAUTH_CLIENT_ID = dependency.tailscale_wif.outputs.client_id
    TS_AUDIENCE        = dependency.tailscale_wif.outputs.audience
    TS_TAGS            = values.tags
  }
}
