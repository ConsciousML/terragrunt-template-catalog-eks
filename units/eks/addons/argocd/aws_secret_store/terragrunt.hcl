include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_kubectl" {
  path = find_in_parent_folders("provider_kubectl.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/aws_external_secret_store/?ref=${values.version}"
}

dependency "iam_role_eso" {
  config_path  = "../../external_secrets_operator/iam_role"
  skip_outputs = true
}

dependency "external_secrets_operator" {
  config_path  = "../../external_secrets_operator/helm"
  skip_outputs = true
}

dependency "argocd" {
  config_path = "../helm"
  mock_outputs = {
    namespace = "argocd"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  name         = "${include.root.locals.environment}-aws-secrets-manager"
  namespace    = dependency.argocd.outputs.namespace
  aws_region   = include.root.locals.aws_region
}
