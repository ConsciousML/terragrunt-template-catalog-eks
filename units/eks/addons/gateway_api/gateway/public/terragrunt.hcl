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
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/gateway/?ref=${values.version}"
}

dependency "namespace" {
  config_path = "../../namespace"
  mock_outputs = {
    name = "gateway"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "gateway_class" {
  config_path = "../../gateway_class"
  mock_outputs = {
    name = "aws-alb"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "load_balancer_configuration_public" {
  config_path = "../../load_balancer_configuration/public"
  mock_outputs = {
    name = "public"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "aws_lbc_gateway_api_crds" {
  config_path  = "../../../aws_load_balancer_controller/gateway_api_crds"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = "public-alb"
  namespace    = dependency.namespace.outputs.name
  spec = {
    gatewayClassName = dependency.gateway_class.outputs.name
    infrastructure = {
      parametersRef = {
        group = "gateway.k8s.aws"
        kind  = "LoadBalancerConfiguration"
        name  = dependency.load_balancer_configuration_public.outputs.name
      }
    }
    listeners = [
      {
        name     = "http"
        protocol = "HTTP"
        port     = 80
        allowedRoutes = {
          namespaces = {
            from = "All"
          }
        }
      },
      {
        name     = "https"
        protocol = "HTTPS"
        port     = 443
        allowedRoutes = {
          namespaces = {
            from = "All"
          }
        }
      }
    ]
  }
}
