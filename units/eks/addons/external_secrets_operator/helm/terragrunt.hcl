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

dependency "iam_role_eso" {
  config_path = "../iam_role"
  mock_outputs = {
    namespace = "external-secrets"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "external-secrets"
  repository         = "https://charts.external-secrets.io"
  chart              = "external-secrets"
  namespace          = dependency.iam_role_eso.outputs.namespace
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
}
