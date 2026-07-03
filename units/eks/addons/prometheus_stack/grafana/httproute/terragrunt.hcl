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

dependency "prometheus_stack" {
  config_path = "../../helm"
  mock_outputs = {
    name      = "kube-prometheus-stack"
    namespace = "monitoring"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "gateway_private" {
  config_path = "../../../gateway_api/gateway/private"
  mock_outputs = {
    name      = "private-alb"
    namespace = "gateway"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

locals {
  domains_hcl            = find_in_parent_folders("domains.hcl")
  domain_private_grafana = read_terragrunt_config(local.domains_hcl).locals.domain_private_grafana
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  api_version  = "gateway.networking.k8s.io/v1"
  kind         = "HTTPRoute"
  name         = "grafana"
  namespace    = dependency.prometheus_stack.outputs.namespace
  annotations = {
    "external-dns.alpha.kubernetes.io/scope" = "private"
  }
  fields = {
    spec = {
      parentRefs = [
        {
          group       = "gateway.networking.k8s.io"
          kind        = "Gateway"
          name        = dependency.gateway_private.outputs.name
          namespace   = dependency.gateway_private.outputs.namespace
          sectionName = "http"
        },
        {
          group       = "gateway.networking.k8s.io"
          kind        = "Gateway"
          name        = dependency.gateway_private.outputs.name
          namespace   = dependency.gateway_private.outputs.namespace
          sectionName = "https"
        }
      ]
      hostnames = [local.domain_private_grafana]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = "${dependency.prometheus_stack.outputs.name}-grafana"
              port = 80
            }
          ]
        }
      ]
    }
  }
}
