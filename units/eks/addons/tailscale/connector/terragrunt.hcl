include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_kubectl" {
  path = find_in_parent_folders("provider_kubectl.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/tailscale_connector/?ref=${values.version}"
}


dependency "vpc" {
  config_path = "../../../../vpc"
  mock_outputs = {
    vpc_cidr_block = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "tailscale_operator" {
  config_path  = "../operator"
  skip_outputs = true
}

inputs = {
  cluster_name     = dependency.eks_cluster.outputs.cluster_name
  name             = "${dependency.eks_cluster.outputs.cluster_name}-connector"
  hostname_prefix  = dependency.eks_cluster.outputs.cluster_name
  advertise_routes = [dependency.vpc.outputs.vpc_cidr_block]
  replicas         = 1
}

