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
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_app_of_apps/?ref=${values.version}"
}

dependency "argocd" {
  config_path  = "../helm"
  skip_outputs = true
}

locals {
  domains_hcl                 = find_in_parent_folders("domains.hcl")
  domain_public_guestbook     = read_terragrunt_config(local.domains_hcl).locals.domain_public_guestbook
  domain_private_argocd       = read_terragrunt_config(local.domains_hcl).locals.domain_private_argocd
  domain_private_grafana      = read_terragrunt_config(local.domains_hcl).locals.domain_private_grafana
  domain_private_prometheus   = read_terragrunt_config(local.domains_hcl).locals.domain_private_prometheus
  domain_private_alertmanager = read_terragrunt_config(local.domains_hcl).locals.domain_private_alertmanager

  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region

  # Single source of truth for the Grafana admin secret's target K8s secret name/key,
  # shared by the grafana-secrets and helm-kube-prometheus-stack appParams entries below.
  grafana_admin_secret_name = "grafana-admin-credentials"
  grafana_admin_secret_key  = "admin-password"
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
    vpc_id         = "mock-vpc-id"
    vpc_cidr_block = "10.0.0.0/16"
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

dependency "tailscale_oauth_client_secret" {
  config_path = "../../tailscale/oauth_client_secret"
  mock_outputs = {
    secret_name = "mock-tailscale-oauth"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "karpenter_iam" {
  config_path = "../../karpenter/iam"
  mock_outputs = {
    queue_name         = "mock-queue"
    node_iam_role_name = "mock-node-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "grafana_password" {
  config_path = "../../prometheus_stack/grafana/aws_password_secret"
  mock_outputs = {
    secret_name = "mock-grafana-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "ebs_csi_driver_addon" {
  config_path  = "../../ebs_csi_driver/addon"
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
  helm_chart_version    = values.helm_chart_version
  retry                 = values.retry
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
        annotations = {
          "external-dns.alpha.kubernetes.io/scope" = "public"
        }
      }
      "gateway-public" = {
        certificateArn = dependency.acm_certificate.outputs.certificate_arn
      }
      "gateway-private" = {
        certificateArn = dependency.acm_certificate.outputs.certificate_arn
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
      "tailscale-secrets" = {
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager"
        awsRegion       = include.root.locals.aws_region
        externalSecrets = [
          {
            name             = "tailscale-operator-oauth"
            targetSecretName = "operator-oauth"
            # ESO is the sole owner of this secret (unlike argocd-secret), and the source
            # OAuth client can be rotated, so create it and keep polling.
            targetCreationPolicy = "Owner"
            refreshPolicy        = "Periodic"
            data = [
              {
                secretKey      = "client_id"
                remoteKey      = dependency.tailscale_oauth_client_secret.outputs.secret_name
                remoteProperty = "client_id"
              },
              {
                secretKey      = "client_secret"
                remoteKey      = dependency.tailscale_oauth_client_secret.outputs.secret_name
                remoteProperty = "client_secret"
              }
            ]
          }
        ]
      }
      "helm-tailscale-connector" = {
        name            = "${dependency.eks_cluster.outputs.cluster_name}-connector"
        hostnamePrefix  = dependency.eks_cluster.outputs.cluster_name
        replicas        = 1
        advertiseRoutes = [dependency.vpc.outputs.vpc_cidr_block]
      }
      "helm-karpenter" = {
        karpenter = {
          settings = {
            clusterName       = dependency.eks_cluster.outputs.cluster_name
            interruptionQueue = dependency.karpenter_iam.outputs.queue_name
          }
        }
      }
      "helm-karpenter-config" = {
        nodeRole    = dependency.karpenter_iam.outputs.node_iam_role_name
        clusterName = dependency.eks_cluster.outputs.cluster_name
      }
      "grafana-secrets" = {
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager"
        awsRegion       = include.root.locals.aws_region
        externalSecrets = [
          {
            name                 = "grafana-admin-password"
            targetSecretName     = local.grafana_admin_secret_name
            targetCreationPolicy = "Owner"
            refreshPolicy        = "CreatedOnce"
            data = [
              {
                secretKey      = local.grafana_admin_secret_key
                remoteKey      = dependency.grafana_password.outputs.secret_name
                remoteProperty = "plaintext"
              }
            ]
          }
        ]
      }
      "helm-kube-prometheus-stack" = {
        "kube-prometheus-stack" = {
          grafana = {
            admin = {
              existingSecret = local.grafana_admin_secret_name
              passwordKey    = local.grafana_admin_secret_key
            }
          }
        }
      }
      "grafana-httproute" = {
        name = "grafana"
        host = local.domain_private_grafana
        backendRef = {
          name = "kube-prometheus-stack-grafana"
          port = 80
        }
        annotations = {
          "external-dns.alpha.kubernetes.io/scope" = "private"
        }
      }
      "prometheus-httproute" = {
        name = "prometheus"
        host = local.domain_private_prometheus
        backendRef = {
          name = "kube-prometheus-stack-prometheus"
          port = 9090
        }
        annotations = {
          "external-dns.alpha.kubernetes.io/scope" = "private"
        }
      }
      "alertmanager-httproute" = {
        name = "alertmanager"
        host = local.domain_private_alertmanager
        backendRef = {
          name = "kube-prometheus-stack-alertmanager"
          port = 9093
        }
        annotations = {
          "external-dns.alpha.kubernetes.io/scope" = "private"
        }
      }
    }
  }
}
