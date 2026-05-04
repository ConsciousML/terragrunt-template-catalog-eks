include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username}/${include.root.locals.github_repo_name}.git//modules/helm_release/?ref=${values.version}"
}

locals {
  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region
}

dependency "vpc" {
  config_path = "../../../vpc"
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "acm_certificate" {
  config_path  = "../../acm_certificate"
  skip_outputs = true
}

dependency "iam_role_aws_lbc" {
  config_path  = "../iam_role_aws_lbc"
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

