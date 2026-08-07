include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_pod_identity/?ref=${values.version}"
}

dependency "cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name    = dependency.cluster.outputs.cluster_name
  iam_role_name   = "${include.root.locals.environment}-ebs-csi-driver"
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"]

  tags = values.tags
}
