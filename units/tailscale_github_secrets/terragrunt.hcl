include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/tailscale_github_secrets?ref=${values.version}"
}

dependency "tailscale_wif" {
  config_path = "../wif"
  mock_outputs = {
    client_id = "mock-client-id"
    audience  = "api.tailscale.com/mock-client-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  github_token     = values.github_token
  github_repo_name = values.github_repo_name
  oauth_client_id  = dependency.tailscale_wif.outputs.client_id
  audience         = dependency.tailscale_wif.outputs.audience
  tags             = values.tags
}
