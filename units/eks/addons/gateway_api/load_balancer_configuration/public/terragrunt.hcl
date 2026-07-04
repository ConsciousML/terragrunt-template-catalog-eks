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

dependency "aws_lbc_gateway_api_crds" {
  config_path  = "../../../aws_load_balancer_controller/gateway_api_crds"
  skip_outputs = true
}

dependency "target_group_configuration_public" {
  config_path = "../../target_group_configuration/public"
  mock_outputs = {
    name = "public-defaults"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "acm_certificate" {
  config_path = "../../../../route53/acm_certificate"
  mock_outputs = {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/mock"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  api_version  = "gateway.k8s.aws/v1beta1"
  kind         = "LoadBalancerConfiguration"
  name         = "public"
  namespace    = dependency.namespace.outputs.name
  fields = {
    spec = {
      scheme = "internet-facing"
      defaultTargetGroupConfiguration = {
        name = dependency.target_group_configuration_public.outputs.name
      }
      listenerConfigurations = [
        {
          protocolPort       = "HTTPS:443"
          defaultCertificate = dependency.acm_certificate.outputs.certificate_arn
        }
      ]
    }
  }
}
