include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_hcl       = find_in_parent_folders("cluster_name_env.hcl")
  cluster_config    = read_terragrunt_config(local.cluster_hcl)
  cluster_name_full = local.cluster_config.locals.cluster_name_full
  environment       = local.cluster_config.locals.environment
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=${values.version}"
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    vpc_id          = "mock_vpc_id"
    private_subnets = ["mock_subnet_id_1", "mock_subnet_id_2"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  name = local.cluster_name_full

  kubernetes_version = values.kubernetes_version

  endpoint_public_access = values.endpoint_public_access

  # Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = values.enable_cluster_creator_admin_permissions

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  # EKS Provisioned Control Plane configuration
  control_plane_scaling_config = values.control_plane_scaling_config

  # More info:
  # https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html
  addons = values.addons

  # EKS Managed Node Group(s)
  eks_managed_node_groups = values.eks_managed_node_groups

  # Disable EKS Auto mode
  compute_config = values.compute_config

  access_entries = try(values.access_entries, {})

  node_security_group_tags = {
    "karpenter.sh/discovery" = local.cluster_name_full
  }

  tags = {
    environment = "${local.environment}"
  }
}