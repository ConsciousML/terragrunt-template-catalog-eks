include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/iam_role_aws_lbc/?ref=${values.version}"
}

dependency "eks_cluster" {
  config_path = "../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name    = dependency.eks_cluster.outputs.cluster_name
  iam_policy_name = "${local.environment}-${values.iam_policy_name}"
  iam_role_name   = "${local.environment}-${values.iam_role_name}"

  iam_policy_url = values.iam_policy_url
  tags           = values.tags
}
