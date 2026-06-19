include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_helm" {
  path = find_in_parent_folders("provider_helm.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/helm_release/?ref=${values.version}"
}


dependency "tailscale_oauth_client_tailscale_operator" {
  config_path = "../oauth_client_tailscale_operator"
  mock_outputs = {
    client_id     = "mock-client-id"
    client_secret = "mock-client-secret"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "tailscale-operator"
  repository         = "https://pkgs.tailscale.com/helmcharts"
  chart              = "tailscale-operator"
  namespace          = "tailscale"
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = {}
  helm_set = [
    {
      name  = "oauth.clientId"
      value = dependency.tailscale_oauth_client_tailscale_operator.outputs.client_id
    }
  ]
  helm_set_sensitive = [
    {
      name  = "oauth.clientSecret"
      value = dependency.tailscale_oauth_client_tailscale_operator.outputs.client_secret
    }
  ]
}

