include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "iam_role_github_actions" {
  config_path = "../../iam_role"
  mock_outputs = {
    role_arn = "arn:aws:iam::123456789012:role/mock-github-actions-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_secrets?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_owner     = include.root.locals.github_owner_catalog
  github_repo_name = values.github_repo_name
  secrets = {
    AWS_REGION   = include.root.locals.aws_region
    AWS_ROLE_ARN = dependency.iam_role_github_actions.outputs.role_arn
  }
}
