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
  domain_private_argocd   = read_terragrunt_config(local.domains_hcl).locals.domain_private_argocd

  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region
}

dependency "route53_hosted_zone_public" {
  config_path = "../../../route53/hosted_zone_public"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "route53_hosted_zone_private" {
  config_path = "../../../route53/hosted_zone_private"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "acm_certificate" {
  config_path = "../../../route53/acm_certificate"
  mock_outputs = {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "vpc" {
  config_path = "../../../../vpc"
  mock_outputs = {
    vpc_id = "mock-vpc-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "iam_role_aws_lbc" {
  config_path  = "../../aws_load_balancer_controller/iam_role"
  skip_outputs = true
}

dependency "iam_role_external_dns_private" {
  config_path  = "../../external_dns/private/iam_role"
  skip_outputs = true
}

dependency "iam_role_external_dns_public" {
  config_path  = "../../external_dns/public/iam_role"
  skip_outputs = true
}

dependency "iam_role_eso" {
  config_path  = "../../external_secrets_operator/iam_role"
  skip_outputs = true
}

dependency "argocd_password" {
  config_path = "../aws_password_secret"
  mock_outputs = {
    secret_name = "mock-argocd-password"
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
      "helm-guestbook" = {
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
      "helm-aws-lbc" = {
        "aws-load-balancer-controller" = {
          clusterName = dependency.eks_cluster.outputs.cluster_name
          region      = local.region
          vpcId       = dependency.vpc.outputs.vpc_id
        }
      }
      "helm-argocd-ingress" = {
        host           = local.domain_private_argocd
        certificateArn = dependency.acm_certificate.outputs.certificate_arn
      }
      "helm-external-dns-private" = {
        "external-dns" = {
          serviceAccount = { name = "external-dns-private" }
          txtOwnerId     = dependency.eks_cluster.outputs.cluster_name
          # The %%% is for escaping Terragrunt templates
          txtPrefix        = "%%%{record_type}-external-dns-private-${dependency.eks_cluster.outputs.cluster_name}."
          domainFilters    = [dependency.route53_hosted_zone_private.outputs.domain_name]
          sources          = ["service", "ingress", "gateway-httproute"]
          provider         = { name = "aws" }
          registry         = "txt"
          policy           = "sync"
          logLevel         = "info"
          annotationFilter = "external-dns.alpha.kubernetes.io/scope=private"
          extraArgs        = { "aws-zone-type" = "private" }
          # React to deletions immediately instead of on the next poll (issue #25)
          triggerLoopOnEvent = true
        }
      }
      "helm-external-dns-public" = {
        "external-dns" = {
          serviceAccount = { name = "external-dns-public" }
          txtOwnerId     = dependency.eks_cluster.outputs.cluster_name
          # The %%% is for escaping Terragrunt templates
          txtPrefix        = "%%%{record_type}-external-dns-public-${dependency.eks_cluster.outputs.cluster_name}."
          domainFilters    = [dependency.route53_hosted_zone_public.outputs.domain_name]
          sources          = ["service", "ingress", "gateway-httproute"]
          provider         = { name = "aws" }
          registry         = "txt"
          policy           = "sync"
          logLevel         = "info"
          annotationFilter = "external-dns.alpha.kubernetes.io/scope=public"
          extraArgs        = { "aws-zone-type" = "public" }
          # React to deletions immediately instead of on the next poll (issue #25)
          triggerLoopOnEvent = true
        }
      }
      "argocd-secrets" = {
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager"
        awsRegion       = include.root.locals.aws_region
        externalSecrets = [
          {
            name                 = "argocd-admin-password"
            targetSecretName     = "argocd-secret"
            targetCreationPolicy = "Merge"
            refreshPolicy        = "CreatedOnce"
            data = [
              {
                secretKey      = "admin.password"
                remoteKey      = dependency.argocd_password.outputs.secret_name
                remoteProperty = "bcrypt_hash"
              }
            ]
          }
        ]
      }
    }
  }
}
