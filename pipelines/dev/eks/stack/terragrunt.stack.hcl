locals {
  version                    = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  version_vpc                = "6.6.0"
  version_cluster            = "21.15.1"
  version_aws_lbc            = "3.2.1"
  version_argocd             = "9.5.0"
  version_external_dns       = "1.20.0"
  version_eso                = "2.4.1"
  version_tailscale_operator = "1.96.5"
  version_karpenter_iam      = "21.24.0"
  version_karpenter_helm     = "1.13.0"
  version_prometheus_stack   = "87.5.0"

  environment       = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
  cluster_name_full = read_terragrunt_config(find_in_parent_folders("cluster_name_env.hcl")).locals.cluster_name_full
  vpc_cidrs         = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs
  vpc_cidr          = local.vpc_cidrs[local.environment]

  private_subnets = [cidrsubnet(local.vpc_cidr, 8, 1), cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 8, 3), cidrsubnet(local.vpc_cidr, 8, 4)]
}

# --- Issue #153: dev stack pared down to what's needed for ArgoCD + app-of-apps bootstrap.
# Everything below is genuine Terraform/Helm infrastructure (not kubernetes_manifest/kubectl_manifest
# based), so it stays wired even though it's not consumed by anything else yet. Deferred units are
# grouped and commented out at the bottom of this file.

# --- VPC + EKS cluster ---

unit "vpc" {
  source = "${get_repo_root()}/units/vpc"
  path   = "vpc"

  values = {
    create_vpc = true
    version    = local.version_vpc

    name = "vpc-eks"

    # For production, use at least 2 subnets
    private_subnets = local.private_subnets
    public_subnets  = local.public_subnets

    enable_nat_gateway     = true
    single_nat_gateway     = false
    one_nat_gateway_per_az = true

    enable_dns_hostnames = true
    enable_dns_support   = true

    public_subnet_tags = {
      # Tag for AWS LBC to know where to deploy external ALB
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      # Tag for AWS LBC to know where to deploy external ALB
      "kubernetes.io/role/internal-elb" = 1
      # Tag for Karpenter to discover the private subnet
      "karpenter.sh/discovery" = local.cluster_name_full
    }
  }
}

unit "cluster" {
  source = "${get_repo_root()}/units/eks/cluster"
  path   = "eks/cluster"

  values = {
    version = local.version_cluster

    kubernetes_version = "1.35"

    # For improved security, should be set to `false`
    # Use Tailscale to access the private endpoint
    endpoint_public_access = true

    # Adds the current caller identity as an administrator via cluster access entry
    enable_cluster_creator_admin_permissions = true

    control_plane_scaling_config = {
      tier = "standard"
    }

    # Run the following command to see all the available addons:
    # aws eks describe-addon-versions --query 'addons[*].addonName' --output text | tr '\t' '\n'
    # Here's the argument reference for the addons:
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
    # Read the following for additional information about the available addons:
    # https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html
    addons = {
      # aws-ebs-csi-driver is installed from units/eks/addons/ebs_csi_driver/addon
      coredns = {}
      eks-pod-identity-agent = {
        before_compute = true
      }
      kube-proxy = {}
      vpc-cni = {
        before_compute = true
        # Prefix delegation: nodes need more IPs than one-per-ENI allows
        configuration_values = jsonencode({
          env = {
            ENABLE_PREFIX_DELEGATION = "true"
          }
        })
      }
    }

    eks_managed_node_groups = {
      "${local.environment}_ng" = {
        # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
        ami_type = "AL2023_x86_64_STANDARD"

        # Pin to a specific AMI release to prevent unintended rolling node replacements on every apply.
        # Find available versions with:
        # aws ssm get-parameters-by-path --path /aws/service/eks/optimized-ami/1.35/amazon-linux-2023/x86_64/standard --query 'Parameters[].Name'
        ami_release_version = "1.35.6-20260618"

        # Use cheapest config for testing purposes
        instance_types = ["t3.medium"]

        # Use at least `min_size = 2` or upgrade the `instance_types`
        # Otherwise some important system components will be stuck in `PENDING` (too many nodes)
        min_size     = 2
        max_size     = 10
        desired_size = 2
      }
    }

    # Disable EKS Auto mode
    compute_config = {
      enabled = false
    }

    # Only needed in the prod environment of the live repository when CI deployed the cluster
    # and you need to run destroy locally. Get your ARN with:
    # aws sts get-caller-identity --query Arn --output text
    access_entries = {}
  }
}

# --- EBS CSI driver ---

unit "ebs_csi_driver_iam_role" {
  source = "${get_repo_root()}/units/eks/addons/ebs_csi_driver/iam_role"
  path   = "eks/addons/ebs_csi_driver/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

unit "ebs_csi_driver_addon" {
  source = "${get_repo_root()}/units/eks/addons/ebs_csi_driver/addon"
  path   = "eks/addons/ebs_csi_driver/addon"

  values = {
    version = local.version
    tags    = {}
  }
}

# --- Route53 + ACM ---

unit "route53_hosted_zone_public" {
  source = "${get_repo_root()}/units/eks/route53/hosted_zone_public"
  path   = "eks/route53/hosted_zone_public"

  values = {
    version = local.version
    comment = "Managed by Terraform"
    create  = false
  }
}

unit "route53_hosted_zone_private" {
  source = "${get_repo_root()}/units/eks/route53/hosted_zone_private"
  path   = "eks/route53/hosted_zone_private"

  values = {
    version = local.version
    comment = "Managed by Terraform"
  }
}

unit "acm_certificate" {
  source = "${get_repo_root()}/units/eks/route53/acm_certificate"
  path   = "eks/route53/acm_certificate"

  values = {
    version = local.version
  }
}

# --- ArgoCD ---

unit "argocd" {
  source = "${get_repo_root()}/units/eks/addons/argocd/helm"
  path   = "eks/addons/argocd/helm"

  values = {
    version            = local.version
    helm_chart_version = local.version_argocd
    helm_values = {
      configs = {
        params = {
          "server.insecure" = true
        }
        cm = {
          # Restores the Application CRD health check ArgoCD removed by default in v1.8+.
          # Without this, sync-wave ordering between nested Applications (app-of-apps) is a
          # no-op: a child Application with no health assessment reports healthy immediately
          # on creation, so a later wave proceeds without waiting for it to actually converge.
          "resource.customizations.health.argoproj.io_Application" = <<-LUA
            hs = {}
            hs.status = "Progressing"
            hs.message = ""
            if obj.status ~= nil then
              if obj.status.health ~= nil then
                hs.status = obj.status.health.status
                if obj.status.health.message ~= nil then
                  hs.message = obj.status.health.message
                end
              end
            end
            return hs
          LUA
        }
      }
      server = {
        ingress = {
          enabled          = true
          controller       = "aws"
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"           = "internal"
            "alb.ingress.kubernetes.io/target-type"      = "ip"
            "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
            "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTP\":80}, {\"HTTPS\":443}]"
            "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
            "external-dns.alpha.kubernetes.io/scope"     = "private"
          }
          aws = {
            serviceType            = "ClusterIP"
            backendProtocolVersion = "GRPC"
          }
        }
      }
    }
  }
}

unit "argocd_app_of_apps" {
  source = "${get_repo_root()}/units/eks/addons/argocd/app_of_apps"
  path   = "eks/addons/argocd/app_of_apps"

  values = {
    version   = local.version
    name      = "app-of-apps"
    namespace = "argocd"
    path      = "apps"
    # TODO: revert to main
    #target_revision       = "main"
    target_revision       = "migrate-tg-k8s-to-app-of-apps"
    project               = "default"
    destination_namespace = "argocd"
    destination_server    = "https://kubernetes.default.svc"
    finalizers            = ["resources-finalizer.argocd.argoproj.io"]
    sync_options          = ["CreateNamespace=true"]
    prune                 = true
  }
}

# --- Karpenter (deferred: not required for ArgoCD bootstrap; NodePool/EC2NodeClass are
# kubernetes_manifest-based and will move to app-of-apps) ---

# unit "karpenter_iam" {
#   source = "${get_repo_root()}/units/eks/addons/karpenter/iam"
#   path   = "eks/addons/karpenter/iam"
#
#   values = {
#     version = local.version_karpenter_iam
#     # Set to true when using `SPOT` instances
#     enable_spot_termination = true
#     tags                    = {}
#   }
# }
#
# unit "karpenter" {
#   source = "${get_repo_root()}/units/eks/addons/karpenter/helm"
#   path   = "eks/addons/karpenter/helm"
#
#   values = {
#     version            = local.version
#     helm_chart_version = local.version_karpenter_helm
#     helm_values = {
#       settings = {
#         enableZonalShift = false
#       }
#       controller = {
#         resources = {
#           requests = {
#             cpu    = "1"
#             memory = "1Gi"
#           }
#           limits = {
#             cpu    = "1"
#             memory = "1Gi"
#           }
#         }
#       }
#     }
#   }
# }
#
# unit "karpenter_ec2_node_class" {
#   source = "${get_repo_root()}/units/eks/addons/karpenter/ec2_node_class"
#   path   = "eks/addons/karpenter/ec2_node_class"
#
#   values = {
#     version            = local.version
#     name               = "default"
#     ami_selector_terms = [{ alias = "al2023@v20260618" }]
#   }
# }
#
# unit "karpenter_node_pool" {
#   source = "${get_repo_root()}/units/eks/addons/karpenter/node_pool"
#   path   = "eks/addons/karpenter/node_pool"
#
#   values = {
#     version = local.version
#     spec = {
#       template = {
#         spec = {
#           requirements = [
#             { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] },
#             { key = "kubernetes.io/os", operator = "In", values = ["linux"] },
#             { key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"] },
#             { key = "karpenter.k8s.aws/instance-category", operator = "In", values = ["c", "m", "r"] },
#             { key = "karpenter.k8s.aws/instance-generation", operator = "Gt", values = ["2"] },
#           ]
#           expireAfter = "720h"
#         }
#       }
#       # Safety net to prevent runaway scaling costs. Increase this value if your
#       # workloads require more compute capacity.
#       limits = {
#         cpu = 10
#       }
#       disruption = {
#         consolidationPolicy = "WhenEmptyOrUnderutilized"
#         consolidateAfter    = "1m"
#       }
#     }
#   }
# }

# --- EBS CSI storage class (deferred: kubernetes_manifest-based, will move to app-of-apps) ---

# unit "ebs_csi_driver_storage_class_gp3" {
#   source = "${get_repo_root()}/units/eks/addons/ebs_csi_driver/storage_class/gp3"
#   path   = "eks/addons/ebs_csi_driver/storage_class/gp3"
#
#   values = {
#     version = local.version
#   }
# }

# --- Prometheus stack (deferred: not required for ArgoCD bootstrap; namespace/SecretStore/
# ExternalSecret/httproute units are kubernetes_manifest-based and will move to app-of-apps) ---

# unit "prometheus_stack_namespace" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/namespace"
#   path   = "eks/addons/prometheus_stack/namespace"
#
#   values = {
#     version = local.version
#     name    = "monitoring"
#   }
# }
#
# unit "grafana_password" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/grafana/aws_password_secret"
#   path   = "eks/addons/prometheus_stack/grafana/aws_password_secret"
#
#   values = {
#     version                 = local.version
#     length                  = 16
#     recovery_window_in_days = 0
#     tags                    = {}
#   }
# }
#
# unit "prometheus_stack_aws_secret_store" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/aws_secret_store"
#   path   = "eks/addons/prometheus_stack/aws_secret_store"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "grafana_aws_external_secret" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/grafana/aws_external_secret"
#   path   = "eks/addons/prometheus_stack/grafana/aws_external_secret"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "prometheus_stack" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/helm"
#   path   = "eks/addons/prometheus_stack/helm"
#
#   values = {
#     version            = local.version
#     helm_chart_version = local.version_prometheus_stack
#     helm_values = {
#       # Pins the generated Service names (e.g. kube-prometheus-stack-prometheus) so the
#       # per-tool httproute/ units (grafana/, prometheus/, alertmanager/) can target them deterministically
#       fullnameOverride = "kube-prometheus-stack"
#
#       # These control plane components are AWS-managed on EKS and not exposed for scraping
#       kubeEtcd              = { enabled = false }
#       kubeScheduler         = { enabled = false }
#       kubeControllerManager = { enabled = false }
#
#       defaultRules = {
#         disabled = {
#           # This node group intentionally runs 2 nodes; the rule can't tell EKS has no
#           # control-plane node label and treats <3 nodes as always failing N+1 tolerance.
#           # Dev-only: do not carry this disable over to staging/prod stacks, where
#           # N+1 node failure tolerance is a real concern the alert should keep catching.
#           KubeCPUOvercommit = true
#         }
#       }
#
#       prometheus = {
#         prometheusSpec = {
#           # Scrape any ServiceMonitor/PodMonitor in the cluster regardless of labels, so
#           # other addons can opt into scraping just by enabling their chart's serviceMonitor
#           serviceMonitorSelectorNilUsesHelmValues = false
#           podMonitorSelectorNilUsesHelmValues     = false
#
#           storageSpec = {
#             volumeClaimTemplate = {
#               spec = {
#                 storageClassName = "gp3"
#                 accessModes      = ["ReadWriteOnce"]
#                 resources        = { requests = { storage = "50Gi" } }
#               }
#             }
#           }
#         }
#       }
#
#       alertmanager = {
#         alertmanagerSpec = {
#           storage = {
#             volumeClaimTemplate = {
#               spec = {
#                 storageClassName = "gp3"
#                 accessModes      = ["ReadWriteOnce"]
#                 resources        = { requests = { storage = "10Gi" } }
#               }
#             }
#           }
#         }
#       }
#
#       # Dashboards/datasources are sidecar-provisioned from ConfigMaps, nothing to persist
#       grafana = {
#         persistence = { enabled = false }
#       }
#     }
#   }
# }
#
# unit "prometheus_stack_httproute_prometheus" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/prometheus/httproute"
#   path   = "eks/addons/prometheus_stack/prometheus/httproute"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "prometheus_stack_httproute_alertmanager" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/alertmanager/httproute"
#   path   = "eks/addons/prometheus_stack/alertmanager/httproute"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "prometheus_stack_httproute_grafana" {
#   source = "${get_repo_root()}/units/eks/addons/prometheus_stack/grafana/httproute"
#   path   = "eks/addons/prometheus_stack/grafana/httproute"
#
#   values = {
#     version = local.version
#   }
# }

# --- ArgoCD admin password via ESO (deferred: using ArgoCD's default auto-generated admin
# password for now; SecretStore/ExternalSecret are kubernetes_manifest-based and will move
# to app-of-apps) ---

# unit "argocd_password" {
#   source = "${get_repo_root()}/units/eks/addons/argocd/aws_password_secret"
#   path   = "eks/addons/argocd/aws_password_secret"
#
#   values = {
#     version                 = local.version
#     length                  = 16
#     recovery_window_in_days = 0
#     tags                    = {}
#   }
# }
#
# unit "argocd_aws_secret_store" {
#   source = "${get_repo_root()}/units/eks/addons/argocd/aws_secret_store"
#   path   = "eks/addons/argocd/aws_secret_store"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "argocd_aws_external_secret" {
#   source = "${get_repo_root()}/units/eks/addons/argocd/aws_external_secret"
#   path   = "eks/addons/argocd/aws_external_secret"
#
#   values = {
#     version = local.version
#   }
# }

# --- External Secrets Operator (deferred: nothing consumes it while the ArgoCD password
# and prometheus_stack ESO units above are deferred) ---

# unit "iam_role_eso" {
#   source = "${get_repo_root()}/units/eks/addons/external_secrets_operator/iam_role"
#   path   = "eks/addons/external_secrets_operator/iam_role"
#
#   values = {
#     version = local.version
#     tags    = {}
#   }
# }
#
# unit "external_secrets_operator" {
#   source = "${get_repo_root()}/units/eks/addons/external_secrets_operator/helm"
#   path   = "eks/addons/external_secrets_operator/helm"
#
#   values = {
#     version            = local.version
#     helm_chart_version = local.version_eso
#     helm_values        = {}
#   }
# }

# --- Gateway API (deferred: kubernetes_manifest/kubectl_manifest-based, will move to
# app-of-apps; guestbook's HTTPRoute won't resolve until then) ---

# unit "gateway_api_crds" {
#   source = "${get_repo_root()}/units/eks/addons/kubectl_manifest_from_url"
#   path   = "eks/addons/gateway_api/crds"
#
#   values = {
#     version = local.version
#     url     = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml"
#   }
# }
#
# unit "aws_lbc_gateway_api_crds" {
#   source = "${get_repo_root()}/units/eks/addons/kubectl_manifest_from_url"
#   path   = "eks/addons/aws_load_balancer_controller/gateway_api_crds"
#
#   values = {
#     version = local.version
#     url     = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${local.version_aws_lbc}/config/crd/gateway/gateway-crds.yaml"
#   }
# }
#
# unit "gateway_api_namespace" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/namespace"
#   path   = "eks/addons/gateway_api/namespace"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_gateway_class" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/gateway_class"
#   path   = "eks/addons/gateway_api/gateway_class"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_target_group_configuration_public" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/target_group_configuration/public"
#   path   = "eks/addons/gateway_api/target_group_configuration/public"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_load_balancer_configuration_public" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/load_balancer_configuration/public"
#   path   = "eks/addons/gateway_api/load_balancer_configuration/public"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_gateway_public" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/gateway/public"
#   path   = "eks/addons/gateway_api/gateway/public"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_target_group_configuration_private" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/target_group_configuration/private"
#   path   = "eks/addons/gateway_api/target_group_configuration/private"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_load_balancer_configuration_private" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/load_balancer_configuration/private"
#   path   = "eks/addons/gateway_api/load_balancer_configuration/private"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "gateway_api_gateway_private" {
#   source = "${get_repo_root()}/units/eks/addons/gateway_api/gateway/private"
#   path   = "eks/addons/gateway_api/gateway/private"
#
#   values = {
#     version = local.version
#   }
# }

# --- AWS Load Balancer Controller + ExternalDNS (deferred: argocd's Ingress will exist but stay
# unfulfilled without these; will move to app-of-apps once Gateway API supersedes ALB Ingress) ---

# unit "iam_policy_aws_lbc" {
#   source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller/iam_policy_url"
#   path   = "eks/addons/aws_load_balancer_controller/iam_policy_url"
#
#   values = {
#     version = local.version
#     url     = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${local.version_aws_lbc}/docs/install/iam_policy.json"
#   }
# }
#
# unit "iam_role_aws_lbc" {
#   source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller/iam_role"
#   path   = "eks/addons/aws_load_balancer_controller/iam_role"
#
#   values = {
#     version = local.version
#     tags    = {}
#   }
# }
#
# unit "aws_load_balancer_controller" {
#   source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller/helm"
#   path   = "eks/addons/aws_load_balancer_controller/helm"
#
#   values = {
#     version                     = local.version
#     helm_chart_version          = local.version_aws_lbc
#     enableServiceMutatorWebhook = false
#   }
# }
#
# unit "iam_role_external_dns_private" {
#   source = "${get_repo_root()}/units/eks/addons/external_dns/private/iam_role"
#   path   = "eks/addons/external_dns/private/iam_role"
#
#   values = {
#     version = local.version
#     tags    = {}
#   }
# }
#
# unit "external_dns_private" {
#   source = "${get_repo_root()}/units/eks/addons/external_dns/private/helm"
#   path   = "eks/addons/external_dns/private/helm"
#
#   values = {
#     version            = local.version
#     helm_chart_version = local.version_external_dns
#     helm_values = {
#       sources = ["service", "ingress", "gateway-httproute"]
#       provider = {
#         name = "aws"
#       }
#       registry         = "txt"
#       policy           = "sync"
#       logLevel         = "info"
#       annotationFilter = "external-dns.alpha.kubernetes.io/scope=private"
#       extraArgs = {
#         "aws-zone-type" = "private"
#       }
#     }
#   }
# }
#
# unit "iam_role_external_dns_public" {
#   source = "${get_repo_root()}/units/eks/addons/external_dns/public/iam_role"
#   path   = "eks/addons/external_dns/public/iam_role"
#
#   values = {
#     version = local.version
#     tags    = {}
#   }
# }
#
# unit "external_dns_public" {
#   source = "${get_repo_root()}/units/eks/addons/external_dns/public/helm"
#   path   = "eks/addons/external_dns/public/helm"
#
#   values = {
#     version            = local.version
#     helm_chart_version = local.version_external_dns
#     helm_values = {
#       sources = ["service", "ingress", "gateway-httproute"]
#       provider = {
#         name = "aws"
#       }
#       registry         = "txt"
#       policy           = "sync"
#       logLevel         = "info"
#       annotationFilter = "external-dns.alpha.kubernetes.io/scope=public"
#       extraArgs = {
#         "aws-zone-type" = "public"
#       }
#     }
#   }
# }

# --- Tailscale (deferred: not required for ArgoCD bootstrap) ---

# unit "tailscale_oauth_client_tailscale_operator" {
#   source = "${get_repo_root()}/units/eks/addons/tailscale/oauth_client_tailscale_operator"
#   path   = "eks/addons/tailscale/oauth_client_tailscale_operator"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "tailscale_operator" {
#   source = "${get_repo_root()}/units/eks/addons/tailscale/operator"
#   path   = "eks/addons/tailscale/operator"
#
#   values = {
#     version            = local.version
#     helm_chart_version = local.version_tailscale_operator
#   }
# }
#
# unit "tailscale_connector" {
#   source = "${get_repo_root()}/units/eks/addons/tailscale/connector"
#   path   = "eks/addons/tailscale/connector"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "tailscale_split_dns" {
#   source = "${get_repo_root()}/units/eks/addons/tailscale/split_dns"
#   path   = "eks/addons/tailscale/split_dns"
#
#   values = {
#     version = local.version
#   }
# }

# --- Domain names (deferred: not required for ArgoCD bootstrap) ---

# unit "domain_name_argocd" {
#   source = "${get_repo_root()}/units/eks/domain_name/argocd"
#   path   = "eks/domain_name/argocd"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "domain_name_guestbook" {
#   source = "${get_repo_root()}/units/eks/domain_name/guestbook"
#   path   = "eks/domain_name/guestbook"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "domain_name_prometheus" {
#   source = "${get_repo_root()}/units/eks/domain_name/prometheus"
#   path   = "eks/domain_name/prometheus"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "domain_name_alertmanager" {
#   source = "${get_repo_root()}/units/eks/domain_name/alertmanager"
#   path   = "eks/domain_name/alertmanager"
#
#   values = {
#     version = local.version
#   }
# }
#
# unit "domain_name_grafana" {
#   source = "${get_repo_root()}/units/eks/domain_name/grafana"
#   path   = "eks/domain_name/grafana"
#
#   values = {
#     version = local.version
#   }
# }
