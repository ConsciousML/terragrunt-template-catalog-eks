include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/iam_pod_identity/?ref=${values.version}"
}

dependency "eks_cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "iam_policy_aws_lbc" {
  config_path = "../iam_policy_url"
  mock_outputs = {
    body = "{}"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name    = dependency.eks_cluster.outputs.cluster_name
  iam_policy_name = "${include.root.locals.environment}-aws-load-balancer-controller-policy"
  iam_role_name   = "${include.root.locals.environment}-aws-load-balancer-controller"
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  iam_policy_json = dependency.iam_policy_aws_lbc.outputs.body

  tags = values.tags
}
