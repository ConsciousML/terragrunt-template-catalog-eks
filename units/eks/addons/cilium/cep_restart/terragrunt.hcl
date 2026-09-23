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

dependency "cilium" {
  config_path  = "../helm"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = "cilium-cep-restart"
  # Bundled locally alongside modules/helm_release, travels with the same git fetch.
  chart            = "../../charts/cilium-cep-restart"
  namespace        = "kube-system"
  create_namespace = false
  # Covers the hook Job's own activeDeadlineSeconds (1200), the apply blocks on it.
  timeout = 1500
  helm_values = {
    ciliumVersion = values.cilium_version
    nodeSelector  = values.node_selector
    tolerations   = values.tolerations
  }
}
