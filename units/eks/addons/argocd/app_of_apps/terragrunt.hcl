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
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/argocd_app_of_apps/?ref=${values.version}"
}

dependency "argocd" {
  config_path  = "../helm"
  skip_outputs = true
}

locals {
  domains_hcl                 = find_in_parent_folders("domains.hcl")
  domain_public_podinfo       = read_terragrunt_config(local.domains_hcl).locals.domain_public_podinfo
  domain_private_argocd       = read_terragrunt_config(local.domains_hcl).locals.domain_private_argocd
  domain_private_grafana      = read_terragrunt_config(local.domains_hcl).locals.domain_private_grafana
  domain_private_prometheus   = read_terragrunt_config(local.domains_hcl).locals.domain_private_prometheus
  domain_private_alertmanager = read_terragrunt_config(local.domains_hcl).locals.domain_private_alertmanager
  domain_private_goldilocks   = read_terragrunt_config(local.domains_hcl).locals.domain_private_goldilocks
  domain_private_hubble       = read_terragrunt_config(local.domains_hcl).locals.domain_private_hubble

  region_hcl = find_in_parent_folders("region.hcl")
  region     = read_terragrunt_config(local.region_hcl).locals.region

  # Shared by kube-prometheus-stack's fullnameOverride and the 3 httproute
  # backendRef names below. Only HCL can compose "<release>-grafana", so it lives here.
  # Must also match tool.helm.releaseName for kube-prometheus-stack in apps/values.yaml
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
  config_path = "../../../../vpc/vpc"
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

dependency "karpenter_helm" {
  config_path  = "../../karpenter/helm"
  skip_outputs = true
}

dependency "karpenter_ec2_node_class" {
  config_path  = "../../karpenter/ec2_node_class"
  skip_outputs = true
}

dependency "karpenter_node_pool_elastic" {
  config_path  = "../../karpenter/node_pool/elastic"
  skip_outputs = true
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

dependency "vpc_endpoint_cidrs" {
  config_path = "../../../../vpc/endpoint_cidrs"
  mock_outputs = {
    vpc_endpoint_cidrs = {
      secretsmanager       = ["10.2.0.10", "10.2.32.10", "10.2.64.10"]
      route53              = ["10.2.0.11", "10.2.32.11", "10.2.64.11"]
      ecrApi               = ["10.2.0.12", "10.2.32.12", "10.2.64.12"]
      ec2                  = ["10.2.0.14", "10.2.32.14", "10.2.64.14"]
      sts                  = ["10.2.0.15", "10.2.32.15", "10.2.64.15"]
      elasticloadbalancing = ["10.2.0.16", "10.2.32.16", "10.2.64.16"]
      sqs                  = ["10.2.0.17", "10.2.32.17", "10.2.64.17"]
      iam                  = ["10.2.0.18", "10.2.32.18", "10.2.64.18"]
      tagging              = ["10.2.0.19", "10.2.32.19", "10.2.64.19"]
    }
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name          = dependency.eks_cluster.outputs.cluster_name
  repo_url              = "https://github.com/${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_app_of_apps}"
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
      "podinfo-httproute" = {
        host = local.domain_public_podinfo
      }
      "gateway-public" = {
        certificateArn = dependency.acm_certificate.outputs.certificate_arn
      }
      "gateway-private" = {
        certificateArn = dependency.acm_certificate.outputs.certificate_arn
      }
      "aws-lbc" = {
        vpcEndpointCidrs = {
          ec2                  = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.ec2
          elasticloadbalancing = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.elasticloadbalancing
          tagging              = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.tagging
        }
        "aws-load-balancer-controller" = {
          clusterName = dependency.eks_cluster.outputs.cluster_name
          region      = local.region
          vpcId       = dependency.vpc.outputs.vpc_id
        }
      }
      "argocd-httproute" = {
        host = local.domain_private_argocd
      }
      "cilium" = {
        cilium = {
          # Bare API server host as KUBERNETES_SERVICE_HOST, cluster_endpoint's https://
          # scheme stripped. Cilium can't rely on kubernetes.default.svc before its own
          # service load-balancing is up.
          k8sServiceHost = trimprefix(dependency.eks_cluster.outputs.cluster_endpoint, "https://")
          k8sServicePort = "443"
        }
      }
      "external-dns-private" = {
        vpcEndpointCidrs = {
          route53 = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.route53
        }
        "external-dns" = {
          txtOwnerId = dependency.eks_cluster.outputs.cluster_name
          # The %%% is for escaping Terragrunt templates
          txtPrefix     = "%%%{record_type}-external-dns-private-${dependency.eks_cluster.outputs.cluster_name}."
          domainFilters = [dependency.route53_hosted_zone_private.outputs.domain_name]
        }
      }
      "external-dns-public" = {
        vpcEndpointCidrs = {
          route53 = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.route53
        }
        "external-dns" = {
          txtOwnerId = dependency.eks_cluster.outputs.cluster_name
          # The %%% is for escaping Terragrunt templates
          txtPrefix     = "%%%{record_type}-external-dns-public-${dependency.eks_cluster.outputs.cluster_name}."
          domainFilters = [dependency.route53_hosted_zone_public.outputs.domain_name]
        }
      }
      "external-secrets-operator" = {
        vpcEndpointCidrs = {
          secretsmanager = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.secretsmanager
        }
      }
      "network-policies-kube-system" = {
        vpcEndpointCidrs = {
          ec2 = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.ec2
          sqs = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.sqs
          iam = dependency.vpc_endpoint_cidrs.outputs.vpc_endpoint_cidrs.iam
        }
      }
      "loki" = {
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
      "tailscale-connector" = {
        name            = "${dependency.eks_cluster.outputs.cluster_name}-connector"
        hostnamePrefix  = dependency.eks_cluster.outputs.cluster_name
        advertiseRoutes = [dependency.vpc.outputs.vpc_cidr_block]
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
      # httproute backendRefs.default.name overrides below must all agree on this same
      # literal. Only HCL locals can compose "<release>-grafana", plain YAML can't.
      "kube-prometheus-stack" = {
        "kube-prometheus-stack" = {
          fullnameOverride = local.kube_prometheus_stack_release
          environment      = include.root.locals.environment
          prometheus = {
            prometheusSpec = {
              externalUrl = "https://${local.domain_private_prometheus}"
            }
          }
          alertmanager = {
            alertmanagerSpec = {
              externalUrl = "https://${local.domain_private_alertmanager}"
            }
          }
        }
      }
      "grafana-httproute" = {
        host = local.domain_private_grafana
        backendRefs = {
          default = {
            name = "${local.kube_prometheus_stack_release}-grafana"
          }
        }
      }
      "prometheus-httproute" = {
        host = local.domain_private_prometheus
        backendRefs = {
          default = {
            name = "${local.kube_prometheus_stack_release}-prometheus"
          }
        }
      }
      "alertmanager-httproute" = {
        host = local.domain_private_alertmanager
        backendRefs = {
          default = {
            name = "${local.kube_prometheus_stack_release}-alertmanager"
          }
        }
      }
      "goldilocks-httproute" = {
        host = local.domain_private_goldilocks
      }
      "hubble-ui-httproute" = {
        host = local.domain_private_hubble
      }
      "blackbox-exporter" = {
        "prometheus-blackbox-exporter" = {
          serviceMonitor = {
            targets = [
              { name = "grafana", url = "https://${local.domain_private_grafana}" },
              { name = "prometheus", url = "https://${local.domain_private_prometheus}" },
              { name = "alertmanager", url = "https://${local.domain_private_alertmanager}" },
              { name = "argocd", url = "https://${local.domain_private_argocd}" },
              { name = "podinfo", url = "https://${local.domain_public_podinfo}" },
              { name = "hubble", url = "https://${local.domain_private_hubble}" },
            ]
          }
        }
      }
    }
  }
}
