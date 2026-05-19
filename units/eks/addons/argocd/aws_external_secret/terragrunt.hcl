include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_kubernetes" {
  path = find_in_parent_folders("provider_kubernetes.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/external_secret/?ref=${values.version}"
}

dependency "aws_secret_store" {
  config_path = "../aws_secret_store"
  mock_outputs = {
    name      = "mock-aws-secrets-manager"
    namespace = "argocd"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "argocd_password" {
  config_path = "../aws_password_secret"
  mock_outputs = {
    secret_name = "mock-argocd-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "argocd" {
  config_path  = "../helm"
  skip_outputs = true
}

dependency "external_secrets_operator" {
  config_path  = "../../external_secrets_operator/helm"
  skip_outputs = true
}

inputs = {
  cluster_name           = dependency.eks_cluster.outputs.cluster_name
  name                   = "argocd-admin-password"
  namespace              = dependency.aws_secret_store.outputs.namespace
  secret_store_name      = dependency.aws_secret_store.outputs.name
  secret_store_kind      = "SecretStore"
  target_secret_name     = "argocd-secret"
  target_creation_policy = "Merge"
  refresh_policy         = "CreatedOnce"
  data = [
    {
      secret_key      = "admin.password"
      remote_key      = dependency.argocd_password.outputs.secret_name
      remote_property = "bcrypt_hash"
    }
  ]
}
