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

  before_hook "wait_for_dns_cleanup" {
    commands = ["destroy"]
    execute  = ["sleep", "60"]
  }
}

dependency "gateway_api_crds" {
  config_path  = "../../../gateway_api/crds"
  skip_outputs = true
}

dependency "aws_load_balancer_controller" {
  config_path  = "../../../aws_load_balancer_controller/helm"
  skip_outputs = true
}

dependency "iam_role_external_dns_public" {
  config_path = "../iam_role"
  mock_outputs = {
    namespace = "external-dns"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "route53_hosted_zone_public" {
  config_path = "../../../../route53/hosted_zone_public"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "external-dns-public"
  repository         = "https://kubernetes-sigs.github.io/external-dns/"
  chart              = "external-dns"
  namespace          = dependency.iam_role_external_dns_public.outputs.namespace
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    {
      name  = "serviceAccount.name"
      value = "external-dns-public"
    },
    {
      name  = "txtOwnerId"
      value = dependency.eks_cluster.outputs.cluster_name
    },
    # The %%% is for escaping Terragrunt templates
    {
      name  = "txtPrefix"
      value = "%%%{record_type}-external-dns-public-${dependency.eks_cluster.outputs.cluster_name}."
    },
    {
      name  = "domainFilters[0]"
      value = dependency.route53_hosted_zone_public.outputs.domain_name
    }
  ]
}
