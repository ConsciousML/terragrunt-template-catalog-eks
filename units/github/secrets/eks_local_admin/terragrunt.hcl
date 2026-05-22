include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "aws_caller_identity" {
  config_path = "../aws_caller_identity"
  mock_outputs = {
    arn = "arn:aws:iam::123456789012:user/mock-user"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_secrets?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_repo_name = values.github_repo_name
  secrets          = { EKS_LOCAL_ADMIN_ARN = dependency.aws_caller_identity.outputs.arn }
}
