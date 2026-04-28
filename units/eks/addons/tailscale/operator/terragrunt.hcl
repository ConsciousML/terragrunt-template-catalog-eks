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
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment

  cluster_config_hcl = find_in_parent_folders("cluster_config.hcl")
  cluster_name       = read_terragrunt_config(local.cluster_config_hcl).locals.cluster_name

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
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "tailscale_oauth_client_tailscale_operator" {
  config_path = "../oauth_client_tailscale_operator"
  mock_outputs = {
    client_id     = "mock-client-id"
    client_secret = "mock-client-secret"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "tailscale-operator"
  repository         = "https://pkgs.tailscale.com/helmcharts"
  chart              = "tailscale-operator"
  namespace          = "tailscale"
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = {}
  helm_set = [
    {
      name  = "oauth.clientId"
      value = dependency.tailscale_oauth_client_tailscale_operator.outputs.client_id
    }
  ]
  helm_set_sensitive = [
    {
      name  = "oauth.clientSecret"
      value = dependency.tailscale_oauth_client_tailscale_operator.outputs.client_secret
    }
  ]
}

exclude {
  if      = !local.cluster_exists
  actions = ["init", "validate", "plan"]
}
