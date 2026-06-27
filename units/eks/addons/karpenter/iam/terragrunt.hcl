include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws//modules/karpenter?version=${values.version}"
}

dependency "eks_cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name

  namespace       = "kube-system"
  service_account = "karpenter"

  enable_spot_termination = values.enable_spot_termination
  enable_inline_policy    = true

  tags = values.tags
}
