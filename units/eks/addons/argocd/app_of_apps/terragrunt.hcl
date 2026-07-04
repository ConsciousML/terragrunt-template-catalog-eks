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
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_app_of_apps/?ref=${values.version}"
}

dependency "argocd" {
  config_path  = "../helm"
  skip_outputs = true
}

locals {
  domains_hcl             = find_in_parent_folders("domains.hcl")
  domain_public_guestbook = read_terragrunt_config(local.domains_hcl).locals.domain_public_guestbook
}

dependency "route53_hosted_zone_public" {
  config_path  = "../../../route53/hosted_zone_public"
  skip_outputs = true
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
        host = local.domain_public_guestbook
        # Hardcoded until the Gateway API units are migrated into app-of-apps (issue #153);
        # matches units/eks/addons/gateway_api/gateway/public's name/namespace.
        gateway = {
          name      = "public-alb"
          namespace = "gateway"
        }
        annotations = {
          "external-dns.alpha.kubernetes.io/scope" = "public"
        }
      }
    }
  }
}
