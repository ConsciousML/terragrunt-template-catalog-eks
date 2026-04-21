include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/helm_release/?ref=${values.version}"
}

locals {
  cluster_config_hcl = find_in_parent_folders("cluster_config.hcl")
  cluster_name       = read_terragrunt_config(local.cluster_config_hcl).locals.cluster_name

  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  dns_config_hcl = find_in_parent_folders("dns_config.hcl")
  domain_name    = read_terragrunt_config(local.dns_config_hcl).locals.domain_name

  cluster_name_full = "${local.environment}-${local.cluster_name}"

  cluster_exists = run_cmd("--terragrunt-quiet", "sh", "-c", <<-EOT
    output=$(aws eks describe-cluster --name ${local.cluster_name_full} 2>&1)
    aws_exit_code=$?
    if echo "$output" | grep -q 'ResourceNotFoundException'; then
      echo false
    elif [ $aws_exit_code -ne 0 ]; then
      echo "$output" >&2
      exit 1
    else
      echo true
    fi
  EOT
  )
}

dependency "eks_cluster" {
  config_path = "../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "aws_load_balancer_controller" {
  config_path  = "../aws_load_balancer_controller"
  skip_outputs = true
}

dependency "external_dns" {
  config_path  = "../external_dns"
  skip_outputs = true
}

dependency "acm_certificate" {
  config_path = "../../acm_certificate"
  mock_outputs = {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
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
      value = local.domain_name
    }
  ]
}

exclude {
  if      = !local.cluster_exists
  actions = ["init", "validate", "plan"]
}
