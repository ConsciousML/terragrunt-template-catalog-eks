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
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_app_of_apps/?ref=${values.version}"
}

dependency "argocd" {
  config_path  = "../helm"
  skip_outputs = true
}

dependency "gateway_public" {
  config_path = "../../gateway_api/gateway/public"
  mock_outputs = {
    name      = "public-alb"
    namespace = "gateway"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "route53_hosted_zone_guestbook_public" {
  config_path = "../../../route53/apps/guestbook/hosted_zone_public"
  mock_outputs = {
    domain_name = "mock.guestbook.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name          = dependency.eks_cluster.outputs.cluster_name
  repo_url              = "https://github.com/${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_app_of_apps}"
  name                  = values.name
  namespace             = values.namespace
  path                  = values.path
  target_revision       = values.target_revision
  project               = values.project
  destination_namespace = values.destination_namespace
  destination_server    = values.destination_server
  finalizers            = values.finalizers
  sync_options          = values.sync_options
  prune                 = values.prune
  helm_values = {
    config = {
      spec = {
        source = {
          targetRevision = values.target_revision
        }
      }
    }
    appParams = {
      "guestbook-helm" = {
        host = dependency.route53_hosted_zone_guestbook_public.outputs.domain_name
        gateway = {
          name      = dependency.gateway_public.outputs.name
          namespace = dependency.gateway_public.outputs.namespace
        }
        annotations = {
          "external-dns.alpha.kubernetes.io/scope" = "public"
        }
      }
    }
  }
}
