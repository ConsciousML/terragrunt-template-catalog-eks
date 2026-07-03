include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/external_secret/?ref=${values.version}"
}

dependency "aws_secret_store" {
  config_path = "../../aws_secret_store"
  mock_outputs = {
    name      = "mock-aws-secrets-manager"
    namespace = "monitoring"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "grafana_password" {
  config_path = "../aws_password_secret"
  mock_outputs = {
    secret_name = "mock-grafana-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "external_secrets_operator" {
  config_path  = "../../../external_secrets_operator/helm"
  skip_outputs = true
}

inputs = {
  cluster_name           = dependency.eks_cluster.outputs.cluster_name
  name                   = "grafana-admin-password"
  namespace              = dependency.aws_secret_store.outputs.namespace
  secret_store_name      = dependency.aws_secret_store.outputs.name
  secret_store_kind      = "SecretStore"
  target_secret_name     = "grafana-admin-credentials"
  target_creation_policy = "Owner"
  refresh_policy         = "CreatedOnce"
  data = [
    {
      secret_key      = "admin-password"
      remote_key      = dependency.grafana_password.outputs.secret_name
      remote_property = "plaintext"
    }
  ]
}
