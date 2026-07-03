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

dependency "ebs_csi_driver_addon" {
  config_path  = "../../ebs_csi_driver/addon"
  skip_outputs = true
}

dependency "ebs_csi_driver_storage_class_gp3" {
  config_path  = "../../ebs_csi_driver/storage_class/gp3"
  skip_outputs = true
}

dependency "namespace" {
  config_path = "../namespace"
  mock_outputs = {
    name = "monitoring"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "grafana_aws_external_secret" {
  config_path = "../grafana/aws_external_secret"
  mock_outputs = {
    target_secret_name = "mock-grafana-admin-credentials"
    secret_key         = "admin-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "kube-prometheus-stack"
  repository         = "https://prometheus-community.github.io/helm-charts"
  chart              = "kube-prometheus-stack"
  namespace          = dependency.namespace.outputs.name
  create_namespace   = false
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    # Admin password is generated in Secrets Manager and synced in via ESO
    # (../grafana/aws_password_secret, ../aws_secret_store, ../grafana/aws_external_secret)
    # into a secret the ESO units own, not one the chart creates
    {
      name  = "grafana.admin.existingSecret"
      value = dependency.grafana_aws_external_secret.outputs.target_secret_name
    },
    {
      name  = "grafana.admin.passwordKey"
      value = dependency.grafana_aws_external_secret.outputs.secret_key
    },
    # Not sensitive: set directly so the chart never needs an `admin-user` field in
    # Secrets Manager just to satisfy its `userKey` mapping
    {
      name  = "grafana.env.GF_SECURITY_ADMIN_USER"
      value = "admin"
    }
  ]
}
