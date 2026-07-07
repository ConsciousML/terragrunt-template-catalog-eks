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

locals {
  domains_hcl           = find_in_parent_folders("domains.hcl")
  domain_private_argocd = read_terragrunt_config(local.domains_hcl).locals.domain_private_argocd
}

dependency "route53_hosted_zone_private" {
  config_path  = "../../../route53/hosted_zone_private"
  skip_outputs = true
}

inputs = {
  cluster_name     = dependency.eks_cluster.outputs.cluster_name
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  # Uninstall can take longer than the provider's 300s default while ArgoCD cascades
  # deletes through its own Applications and their managed resources.
  timeout            = 600
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    {
      name  = "global.domain"
      value = local.domain_private_argocd
    }
  ]
}