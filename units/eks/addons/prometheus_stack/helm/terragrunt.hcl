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

dependency "ebs_csi_driver_addon" {
  config_path  = "../../ebs_csi_driver/addon"
  skip_outputs = true
}

dependency "ebs_csi_driver_storage_class_gp3" {
  config_path  = "../../ebs_csi_driver/storage_class/gp3"
  skip_outputs = true
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "kube-prometheus-stack"
  repository         = "https://prometheus-community.github.io/helm-charts"
  chart              = "kube-prometheus-stack"
  namespace          = "monitoring"
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
}
