include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/k8s_rbac_cluster_role/?ref=${values.version}"
}

dependency "argocd" {
  config_path  = "../../../helm"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = "argocd-server-cluster-apps"
  labels = {
    "app.kubernetes.io/name"      = "argocd-server-cluster-apps"
    "app.kubernetes.io/part-of"   = "argocd"
    "app.kubernetes.io/component" = "server"
  }
  rules = [
    {
      api_groups = [""]
      resources  = ["events"]
      verbs      = ["create"]
    },
    {
      api_groups = ["argoproj.io"]
      resources  = ["applications"]
      verbs      = ["create", "delete", "update", "patch"]
    }
  ]
}
