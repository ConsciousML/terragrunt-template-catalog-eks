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
  config_path  = "../../gateway_api/crds"
  skip_outputs = true
}

dependency "aws_load_balancer_controller" {
  config_path  = "../../aws_load_balancer_controller/helm"
  skip_outputs = true
}

dependency "iam_role_external_dns" {
  config_path = "../iam_role"
  mock_outputs = {
    namespace = "external-dns"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "route53_hosted_zone_private" {
  config_path = "../../../route53/argocd/hosted_zone_private"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "external-dns"
  repository         = "https://kubernetes-sigs.github.io/external-dns/"
  chart              = "external-dns"
  namespace          = dependency.iam_role_external_dns.outputs.namespace
  create_namespace   = true
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
  helm_set = [
    {
      name  = "txtOwnerId"
      value = dependency.eks_cluster.outputs.cluster_name
    },
    # Prefix or Suffix are mandatory for the external-dns to create the TXT records for ownership
    # It is necessary for it to delete the A/AAAA records when an Ingress resource is deleted
    # "%{record_type}" is for using the record type as prefix, i.e "cname-external-dns-your-cluster.argocd.yourdomain.com"
    # Instead of "external-dns-your-cluster.cname-argocd.yourdomain.com". In the later case, ownership will fail cause
    # external-dns will not find a the domain "cname-argocd.yourdomain.com" 

    # The %%% is for escaping Terragrunt templates
    {
      name  = "txtPrefix"
      value = "%%%{record_type}-external-dns-${dependency.eks_cluster.outputs.cluster_name}."
    },
    {
      name  = "domainFilters[0]"
      value = dependency.route53_hosted_zone_private.outputs.domain_name
    }
  ]
}

