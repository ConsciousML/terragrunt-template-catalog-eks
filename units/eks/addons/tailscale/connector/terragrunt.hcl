include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_kubernetes" {
  path   = find_in_parent_folders("provider_kubernetes.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/tailscale_connector/?ref=${values.version}"
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
  name             = "${include.provider_kubernetes.locals.cluster_name_full}-connector"
  hostname_prefix  = include.provider_kubernetes.locals.cluster_name_full
  advertise_routes = [dependency.vpc.outputs.vpc_cidr_block]
  replicas         = 1
}

