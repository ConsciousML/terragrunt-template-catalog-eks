include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  cluster_name_full = read_terragrunt_config(find_in_parent_folders("cluster_name_env.hcl")).locals.cluster_name_full
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_pod_identity/?ref=${values.version}"
}

inputs = {
  cluster_name    = local.cluster_name_full
  iam_role_name   = "${include.root.locals.environment}-ebs-csi-driver"
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicyV2"]

  tags = values.tags
}
