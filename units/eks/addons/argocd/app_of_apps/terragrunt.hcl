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

  # Shared by helm-kube-prometheus-stack's fullnameOverride and the 3 helm-httproute
  # backendRef names below. Only HCL can compose "<release>-grafana", so it lives here.
  # Must also match tool.helm.releaseName for helm-kube-prometheus-stack in apps/values.yaml
  # (argocd-app-of-apps-template repo), which appParams has no path to set.
  kube_prometheus_stack_release = "kube-prometheus-stack"
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

dependency "loki_s3_chunks" {
  config_path = "../../loki/s3/chunks"
  mock_outputs = {
    s3_bucket_id = "mock-loki-chunks"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "loki_s3_ruler" {
  config_path = "../../loki/s3/ruler"
  mock_outputs = {
    s3_bucket_id = "mock-loki-ruler"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "iam_role_loki" {
  config_path  = "../../loki/iam_role"
  skip_outputs = true
}

dependency "argocd_password" {
  config_path = "../aws_secret_password"
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
  config_path = "../../prometheus_stack/grafana/aws_secret_password"
  mock_outputs = {
    secret_name = "mock-grafana-password"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "alertmanager_slack_bot_secret" {
  config_path = "../../prometheus_stack/alertmanager/aws_secret_slack_bot"
  mock_outputs = {
    secret_name = "mock-alertmanager-slack-bot"
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
      "guestbook-httproute" = {
        host = local.domain_public_guestbook
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
          txtOwnerId = dependency.eks_cluster.outputs.cluster_name
          # The %%% is for escaping Terragrunt templates
          txtPrefix     = "%%%{record_type}-external-dns-private-${dependency.eks_cluster.outputs.cluster_name}."
          domainFilters = [dependency.route53_hosted_zone_private.outputs.domain_name]
        }
      }
      "helm-external-dns-public" = {
        "external-dns" = {
          txtOwnerId = dependency.eks_cluster.outputs.cluster_name
          # The %%% is for escaping Terragrunt templates
          txtPrefix     = "%%%{record_type}-external-dns-public-${dependency.eks_cluster.outputs.cluster_name}."
          domainFilters = [dependency.route53_hosted_zone_public.outputs.domain_name]
        }
      }
      "helm-loki" = {
        loki = {
          loki = {
            storage = {
              bucketNames = {
                chunks = dependency.loki_s3_chunks.outputs.s3_bucket_id
                ruler  = dependency.loki_s3_ruler.outputs.s3_bucket_id
              }
              s3 = {
                region = local.region
              }
            }
          }
        }
      }
      "argocd-secrets" = {
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager-argocd"
        awsRegion       = include.root.locals.aws_region
        remoteKey       = dependency.argocd_password.outputs.secret_name
      }
      "tailscale-secrets" = {
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager-tailscale"
        awsRegion       = include.root.locals.aws_region
        remoteKey       = dependency.tailscale_oauth_client_secret.outputs.secret_name
      }
      "helm-tailscale-connector" = {
        name            = "${dependency.eks_cluster.outputs.cluster_name}-connector"
        hostnamePrefix  = dependency.eks_cluster.outputs.cluster_name
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
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager-grafana"
        awsRegion       = include.root.locals.aws_region
        remoteKey       = dependency.grafana_password.outputs.secret_name
      }
      "alertmanager-secrets" = {
        secretStoreName = "${include.root.locals.environment}-aws-secrets-manager-alertmanager"
        awsRegion       = include.root.locals.aws_region
        remoteKey       = dependency.alertmanager_slack_bot_secret.outputs.secret_name
      }
      # See local.kube_prometheus_stack_release above: fullnameOverride and the 3
      # helm-httproute backendRef names below must all agree on this same literal, and only
      # HCL locals can compose "<release>-grafana" — Helm/YAML values files can't.
      "helm-kube-prometheus-stack" = {
        "kube-prometheus-stack" = {
          fullnameOverride = local.kube_prometheus_stack_release
          alertmanager = {
            config = {
              global = {
                slack_app_url = values.slack_app_url
              }
            }
          }
        }
      }
      "grafana-httproute" = {
        host = local.domain_private_grafana
        backendRef = {
          name = "${local.kube_prometheus_stack_release}-grafana"
        }
      }
      "prometheus-httproute" = {
        host = local.domain_private_prometheus
        backendRef = {
          name = "${local.kube_prometheus_stack_release}-prometheus"
        }
      }
      "alertmanager-httproute" = {
        host = local.domain_private_alertmanager
        backendRef = {
          name = "${local.kube_prometheus_stack_release}-alertmanager"
        }
      }
    }
  }
}
