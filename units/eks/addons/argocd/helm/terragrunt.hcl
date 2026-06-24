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

dependency "aws_load_balancer_controller" {
  config_path  = "../../aws_load_balancer_controller/helm"
  skip_outputs = true
}

dependency "external_dns" {
  config_path  = "../../external_dns/private/helm"
  skip_outputs = true
}

locals {
  domains_hcl   = find_in_parent_folders("domains.hcl")
  domain_argocd = read_terragrunt_config(local.domains_hcl).locals.domain_argocd
}

dependency "acm_certificate" {
  config_path = "../../../route53/acm_certificate"
  mock_outputs = {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "route53_hosted_zone_private" {
  config_path  = "../../../route53/hosted_zone_private"
  skip_outputs = true
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "argocd"
  repository         = "https://argoproj.github.io/argo-helm"
  chart              = "argo-cd"
  namespace          = "argocd"
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    {
      name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
      value = dependency.acm_certificate.outputs.certificate_arn
    },
    {
      name  = "global.domain"
      value = local.domain_argocd
    }
  ]
}