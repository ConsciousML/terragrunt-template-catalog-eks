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

# If your stack uses fck-nat, add an ordering-only `dependency "fck_nat"` via `autoinclude` on
# this unit. Example: pipelines/dev/eks/stack/terragrunt.stack.hcl.

dependency "vpc" {
  config_path = "../../vpc/vpc"
  mock_outputs = {
    vpc_id          = "mock_vpc_id"
    private_subnets = ["mock_subnet_id_1", "mock_subnet_id_2"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  name = local.cluster_name_full

  kubernetes_version = values.kubernetes_version

  endpoint_public_access  = values.endpoint_public_access
  endpoint_private_access = values.endpoint_private_access

  # Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = values.enable_cluster_creator_admin_permissions

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  # EKS Provisioned Control Plane configuration
  control_plane_scaling_config = values.control_plane_scaling_config

  enabled_log_types                      = values.enabled_log_types
  cloudwatch_log_group_class             = values.cloudwatch_log_group_class
  cloudwatch_log_group_retention_in_days = values.cloudwatch_log_group_retention_in_days

  # Run the following command to see all the available addons:
  # aws eks describe-addon-versions --query 'addons[*].addonName' --output text | tr '\t' '\n'
  # Here's the argument reference for the addons:
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
  # Read the following for additional information about the available addons:
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