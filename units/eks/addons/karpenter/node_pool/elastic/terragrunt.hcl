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
  config_path = "../../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "karpenter_ec2_node_class" {
  config_path = "../../ec2_node_class"
  mock_outputs = {
    name = "mock-default"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = values.name
  # Bundled locally alongside modules/helm_release, travels with the same git fetch.
  chart            = "../../charts/karpenter-node-pool"
  namespace        = "kube-system"
  create_namespace = false
  helm_values = {
    name = values.name
    # helm_release's "name" output equals the EC2NodeClass's metadata.name, the chart
    # templates it straight from .Values.name.
    ec2NodeClassName       = dependency.karpenter_ec2_node_class.outputs.name
    requirements           = values.requirements
    taints                 = values.taints
    limitsCpu              = values.limits_cpu
    kubeletMaxPods         = values.kubelet_max_pods
    terminationGracePeriod = try(values.termination_grace_period, null)
    expireAfter            = try(values.expire_after, null)
    disruption             = values.disruption
  }
}
