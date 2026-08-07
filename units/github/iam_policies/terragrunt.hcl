include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "iam_role_github_actions" {
  config_path = "../iam_role"
  mock_outputs = {
    role_name = "mock-github-actions-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_policies?ref=${values.version}"
}

inputs = {
  role_name   = dependency.iam_role_github_actions.outputs.role_name
  policy_arns = values.policy_arns
}
