include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/eks_addon/?ref=${values.version}"
}

dependency "cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "iam_role" {
  config_path                             = "../iam_role"
  mock_outputs                            = {}
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name         = dependency.cluster.outputs.cluster_name
  addon_name           = "aws-ebs-csi-driver"
  addon_version        = values.addon_version
  configuration_values = try(values.configuration_values, null)
  tags                 = values.tags
}
