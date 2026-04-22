include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/helm_release/?ref=${values.version}"

  before_hook "wait_for_dns_cleanup" {
    commands = ["destroy"]
    execute  = ["sleep", "60"]
  }
}

locals {
  cluster_config_hcl = find_in_parent_folders("cluster_config.hcl")
  cluster_name       = read_terragrunt_config(local.cluster_config_hcl).locals.cluster_name

  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

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

dependency "iam_role_external_dns" {
  config_path  = "../iam_role_external_dns"
  skip_outputs = true
}

dependency "route53_hosted_zone" {
  config_path = "../../route53_hosted_zone"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "external-dns"
  repository         = "https://kubernetes-sigs.github.io/external-dns/"
  chart              = "external-dns"
  namespace          = "external-dns"
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    {
      name  = "txtOwnerId"
      value = local.cluster_name_full
    },
    # Prefix or Suffix are mandatory for the external-dns to create the TXT records for ownership
    # It is necessary for it to delete the A/AAAA records when an Ingress resource is deleted
    # "%{record_type}" is for using the record type as prefix, i.e "cname-external-dns-your-cluster.argocd.yourdomain.com"
    # Instead of "external-dns-your-cluster.cname-argocd.yourdomain.com". In the later case, ownership will fail cause
    # external-dns will not find a the domain "cname-argocd.yourdomain.com" 

    # The %%% is for escaping Terragrunt templates
    {
      name  = "txtPrefix"
      value = "%%%{record_type}-external-dns-${local.cluster_name_full}."
    },
    {
      name  = "domainFilters[0]"
      value = dependency.route53_hosted_zone.outputs.domain_name
    }
  ]
}

exclude {
  if      = !local.cluster_exists
  actions = ["init", "validate", "plan"]
}