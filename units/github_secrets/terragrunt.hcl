include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region
}

dependency "iam_role_github_actions" {
  config_path = "../iam_role_github_actions"
  mock_outputs = {
    role_arn = "arn:aws:iam::123456789012:role/mock-github-actions-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//modules/github_secrets?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_repo_name = values.github_repo_name
  aws_region       = local.region
  aws_role_arn     = dependency.iam_role_github_actions.outputs.role_arn
}
