include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "iam_role_github_actions" {
  config_path = "../iam_role_github_actions"
  mock_outputs = {
    role_name = "mock-github-actions-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//modules/iam_policies?ref=${values.version}"
}

inputs = {
  role_name   = dependency.iam_role_github_actions.outputs.role_name
  policy_arns = values.policy_arns
}
