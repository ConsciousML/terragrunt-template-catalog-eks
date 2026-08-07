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
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/helm_release/?ref=${values.version}"
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "prometheus-operator-crds"
  repository         = "https://prometheus-community.github.io/helm-charts"
  chart              = "prometheus-operator-crds"
  namespace          = "kube-system"
  create_namespace   = false
  helm_chart_version = values.helm_chart_version
}
