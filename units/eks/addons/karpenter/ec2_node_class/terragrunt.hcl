include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/karpenter_ec2_node_class/?ref=${values.version}"
}

dependency "karpenter_helm" {
  config_path  = "../helm"
  skip_outputs = true
}

dependency "karpenter_iam" {
  config_path = "../iam"
  mock_outputs = {
    node_iam_role_name = "mock-node-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = values.name
  spec = {
    role             = dependency.karpenter_iam.outputs.node_iam_role_name
    amiSelectorTerms = values.ami_selector_terms
    subnetSelectorTerms = [
      { tags = { "karpenter.sh/discovery" = dependency.eks_cluster.outputs.cluster_name } }
    ]
    securityGroupSelectorTerms = [
      { tags = { "karpenter.sh/discovery" = dependency.eks_cluster.outputs.cluster_name } }
    ]
  }
}
