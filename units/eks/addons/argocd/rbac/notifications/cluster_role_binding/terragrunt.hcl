include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/k8s_rbac_cluster_role_binding/?ref=${values.version}"
}

dependency "argocd" {
  config_path  = "../../../helm"
  skip_outputs = true
}

dependency "cluster_role" {
  config_path = "../cluster_role"
  mock_outputs = {
    name = "argocd-notifications-controller-cluster-apps"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = "argocd-notifications-controller-cluster-apps"
  labels = {
    "app.kubernetes.io/name"      = "argocd-notifications-controller-cluster-apps"
    "app.kubernetes.io/part-of"   = "argocd"
    "app.kubernetes.io/component" = "notifications-controller"
  }
  role_ref = {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = dependency.cluster_role.outputs.name
  }
  subjects = [
    {
      kind      = "ServiceAccount"
      name      = "argocd-notifications-controller"
      namespace = "argocd"
    }
  ]
}
