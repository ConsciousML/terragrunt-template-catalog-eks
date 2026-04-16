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

  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region

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
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

dependency "vpc" {
  config_path = "../../../vpc"
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

dependency "acm_certificate" {
  config_path  = "../../acm_certificate"
  skip_outputs = true
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "aws-load-balancer-controller"
  repository         = "https://aws.github.io/eks-charts"
  chart              = "aws-load-balancer-controller"
  namespace          = "kube-system"
  create_namespace   = false
  helm_chart_version = values.helm_chart_version
  helm_values = {
    clusterName = dependency.eks_cluster.outputs.cluster_name
    region      = local.region
    vpcId       = dependency.vpc.outputs.vpc_id
  }
}

exclude {
  if      = !local.cluster_exists
  actions = ["init", "validate", "plan"]
}
