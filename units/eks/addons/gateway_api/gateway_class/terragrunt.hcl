include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/k8s_manifest/?ref=${values.version}"
}

dependency "gateway_api_crds" {
  config_path  = "../crds"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  api_version  = "gateway.networking.k8s.io/v1"
  kind         = "GatewayClass"
  name         = "aws-alb"
  fields = {
    spec = {
      controllerName = "gateway.k8s.aws/alb"
    }
  }
}
