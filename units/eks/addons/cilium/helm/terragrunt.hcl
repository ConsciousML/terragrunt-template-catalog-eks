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

dependency "prometheus_operator_crds" {
  config_path  = "../../prometheus_stack/crds"
  skip_outputs = true
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "cilium"
  repository         = "https://helm.cilium.io"
  chart              = "cilium"
  namespace          = "kube-system"
  create_namespace   = false
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    # Agent must reach the API server before its own service load-balancing is up, can't use
    # kubernetes.default.svc. Bare host, cluster_endpoint's https:// scheme stripped.
    {
      name  = "k8sServiceHost"
      value = trimprefix(dependency.eks_cluster.outputs.cluster_endpoint, "https://")
    },
    {
      name  = "k8sServicePort"
      value = "443"
    }
  ]
}
