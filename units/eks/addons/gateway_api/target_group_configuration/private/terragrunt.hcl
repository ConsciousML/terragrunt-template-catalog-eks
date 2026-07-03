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
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/kubectl_manifest/?ref=${values.version}"
}

dependency "namespace" {
  config_path = "../../namespace"
  mock_outputs = {
    name = "gateway"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "gateway_api_crds" {
  config_path  = "../../crds"
  skip_outputs = true
}

dependency "aws_lbc_gateway_api_crds" {
  config_path  = "../../../aws_load_balancer_controller/gateway_api_crds"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  api_version  = "gateway.k8s.aws/v1beta1"
  kind         = "TargetGroupConfiguration"
  name         = "private-defaults"
  namespace    = dependency.namespace.outputs.name
  fields = {
    spec = {
      defaultConfiguration = {
        targetType = "ip"
      }
    }
  }
}
