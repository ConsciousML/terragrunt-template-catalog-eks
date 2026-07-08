include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/aws_secretsmanager_secret/?ref=${values.version}"
}

dependency "oauth_client_tailscale_operator" {
  config_path = "../oauth_client_tailscale_operator"
  mock_outputs = {
    client_id     = "mock-client-id"
    client_secret = "mock-client-secret"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  name = "${include.root.locals.environment}-tailscale-operator-oauth"
  secret_data = {
    client_id     = dependency.oauth_client_tailscale_operator.outputs.client_id
    client_secret = dependency.oauth_client_tailscale_operator.outputs.client_secret
  }
  recovery_window_in_days = values.recovery_window_in_days
  tags                    = values.tags
}
