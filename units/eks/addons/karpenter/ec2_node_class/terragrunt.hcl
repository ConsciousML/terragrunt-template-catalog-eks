include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_helm" {
  path = find_in_parent_folders("provider_helm.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/helm_release/?ref=${values.version}"
}

dependency "eks_cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "karpenter_iam" {
  config_path = "../iam"
  mock_outputs = {
    node_iam_role_name = "mock-node-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "karpenter_helm" {
  config_path  = "../helm"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = values.name
  # Bundled locally alongside modules/helm_release, travels with the same git fetch.
  chart            = "../../charts/karpenter-ec2-node-class"
  namespace        = "kube-system"
  create_namespace = false
  helm_values = {
    name        = values.name
    nodeRole    = dependency.karpenter_iam.outputs.node_iam_role_name
    clusterName = dependency.eks_cluster.outputs.cluster_name
    amiAlias    = values.ami_alias
  }
}
