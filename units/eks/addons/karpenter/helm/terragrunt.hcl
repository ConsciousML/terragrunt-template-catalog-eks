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
    queue_name = "mock-queue"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "prometheus_operator_crds" {
  config_path  = "../../prometheus_stack/crds"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  # Must match the Pod Identity association's expected ServiceAccount name (units/eks/addons/karpenter/iam).
  name               = "karpenter"
  repository         = "oci://public.ecr.aws/karpenter"
  chart              = "karpenter"
  namespace          = "kube-system"
  create_namespace   = false
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    {
      name  = "settings.clusterName"
      value = dependency.eks_cluster.outputs.cluster_name
    },
    {
      name  = "settings.interruptionQueue"
      value = dependency.karpenter_iam.outputs.queue_name
    }
  ]
}
