include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/argocd/?ref=${values.version}"
}

locals {
  cluster_config_hcl = find_in_parent_folders("cluster_config.hcl")
  cluster_name       = read_terragrunt_config(local.cluster_config_hcl).locals.cluster_name

  cluster_exists = run_cmd("--terragrunt-quiet", "sh", "-c", <<-EOT
    output=$(aws eks describe-cluster --name ${local.cluster_name} 2>&1)
    if echo "$output" | grep -q 'ResourceNotFoundException'; then
      echo false
    elif [ $? -ne 0 ]; then
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
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
}

exclude {
  if      = !local.cluster_exists
  actions = ["init", "validate", "plan"]
}
