locals {
  version                    = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  version_vpc                = "6.6.0"
  version_cluster            = "21.15.1"
  version_aws_lbc            = "3.2.1"
  version_argocd             = "9.5.0"
  version_external_dns       = "1.20.0"
  version_eso                = "2.4.1"
  version_tailscale_operator = "1.96.5"

  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
  vpc_cidrs   = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs
  vpc_cidr    = local.vpc_cidrs[local.environment]

  private_subnets = [cidrsubnet(local.vpc_cidr, 8, 1), cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 8, 3), cidrsubnet(local.vpc_cidr, 8, 4)]
}

unit "route53_hosted_zone_argocd_public" {
  source = "${get_repo_root()}/units/eks/route53/argocd/hosted_zone_public"
  path   = "eks/route53/argocd/hosted_zone_public"

  values = {
    version = local.version
    comment = "Managed by Terraform"
    create  = false
  }
}

unit "vpc" {
  source = "${get_repo_root()}/units/vpc"
  path   = "vpc"

  values = {
    create_vpc = true
    version    = local.version_vpc

    name = "vpc-eks"

    # For production, use at least 3 subnets
    private_subnets = local.private_subnets
    public_subnets  = local.public_subnets

    enable_nat_gateway     = true
    single_nat_gateway     = false
    one_nat_gateway_per_az = true

    enable_dns_hostnames = true
    enable_dns_support   = true

    public_subnet_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = 1
    }
  }
}

unit "cluster" {
  source = "${get_repo_root()}/units/eks/cluster"
  path   = "eks/cluster"

  values = {
    version = local.version_cluster

    kubernetes_version = "1.35"

    endpoint_public_access = true

    # Adds the current caller identity as an administrator via cluster access entry
    enable_cluster_creator_admin_permissions = true

    control_plane_scaling_config = {
      tier = "standard"
    }

    # More info:
    # https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html
    addons = {
      coredns = {}
      eks-pod-identity-agent = {
        before_compute = true
      }
      kube-proxy = {}
      vpc-cni = {
        before_compute = true
      }
    }

    eks_managed_node_groups = {
      example = {
        # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
        ami_type = "AL2023_x86_64_STANDARD"

        # Use cheapest config for testing purposes
        instance_types = ["t3.medium"]

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

unit "iam_policy_aws_lbc" {
  source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller/iam_policy_url"
  path   = "eks/addons/aws_load_balancer_controller/iam_policy_url"

  values = {
    version = local.version
    url     = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${local.version_aws_lbc}/docs/install/iam_policy.json"
  }
}

unit "iam_role_aws_lbc" {
  source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller/iam_role"
  path   = "eks/addons/aws_load_balancer_controller/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

unit "aws_load_balancer_controller" {
  source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller/helm"
  path   = "eks/addons/aws_load_balancer_controller/helm"

  values = {
    version                     = local.version
    helm_chart_version          = local.version_aws_lbc
    enableServiceMutatorWebhook = false
  }
}

unit "argocd_password" {
  source = "${get_repo_root()}/units/eks/addons/argocd/aws_password_secret"
  path   = "eks/addons/argocd/aws_password_secret"

  values = {
    version                 = local.version
    length                  = 16
    recovery_window_in_days = 0
    tags                    = {}
  }
}

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

unit "route53_hosted_zone_argocd_private" {
  source = "${get_repo_root()}/units/eks/route53/argocd/hosted_zone_private"
  path   = "eks/route53/argocd/hosted_zone_private"

  values = {
    version = local.version
    comment = "Managed by Terraform"
  }
}

unit "gateway_api_crds" {
  source = "${get_repo_root()}/units/eks/addons/kubectl_manifest_from_url"
  path   = "eks/addons/gateway_api/crds"

  values = {
    version = local.version
    url     = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml"
  }
}

unit "iam_role_external_dns" {
  source = "${get_repo_root()}/units/eks/addons/external_dns/iam_role"
  path   = "eks/addons/external_dns/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

unit "external_dns" {
  source = "${get_repo_root()}/units/eks/addons/external_dns/helm"
  path   = "eks/addons/external_dns/helm"

  values = {
    version            = local.version
    helm_chart_version = local.version_external_dns
    helm_values = {
      sources = ["service", "ingress", "gateway-httproute"]
      provider = {
        name = "aws"
      }
      registry         = "txt"
      policy           = "sync"
      logLevel         = "info"
      annotationFilter = "external-dns.alpha.kubernetes.io/scope=private"
      extraArgs = {
        "aws-zone-type" = "private"
      }
    }
  }
}

unit "acm_certificate_argocd" {
  source = "${get_repo_root()}/units/eks/route53/argocd/acm_certificate"
  path   = "eks/route53/argocd/acm_certificate"

  values = {
    version = local.version
  }
}

unit "route53_hosted_zone_guestbook_public" {
  source = "${get_repo_root()}/units/eks/route53/apps/guestbook/hosted_zone_public"
  path   = "eks/route53/apps/guestbook/hosted_zone_public"

  values = {
    version = local.version
    comment = "Managed by Terraform"
    create  = false
  }
}

unit "acm_certificate_guestbook" {
  source = "${get_repo_root()}/units/eks/route53/apps/guestbook/acm_certificate"
  path   = "eks/route53/apps/guestbook/acm_certificate"

  values = {
    version = local.version
  }
}

unit "iam_role_eso" {
  source = "${get_repo_root()}/units/eks/addons/external_secrets_operator/iam_role"
  path   = "eks/addons/external_secrets_operator/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

unit "external_secrets_operator" {
  source = "${get_repo_root()}/units/eks/addons/external_secrets_operator/helm"
  path   = "eks/addons/external_secrets_operator/helm"

  values = {
    version            = local.version
    helm_chart_version = local.version_eso
    helm_values        = {}
  }
}

unit "argocd_aws_secret_store" {
  source = "${get_repo_root()}/units/eks/addons/argocd/aws_secret_store"
  path   = "eks/addons/argocd/aws_secret_store"

  values = {
    version = local.version
  }
}

unit "argocd_aws_external_secret" {
  source = "${get_repo_root()}/units/eks/addons/argocd/aws_external_secret"
  path   = "eks/addons/argocd/aws_external_secret"

  values = {
    version = local.version
  }
}

unit "tailscale_oauth_client_tailscale_operator" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/oauth_client_tailscale_operator"
  path   = "eks/addons/tailscale/oauth_client_tailscale_operator"

  values = {
    version = local.version
  }
}

unit "tailscale_operator" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/operator"
  path   = "eks/addons/tailscale/operator"

  values = {
    version            = local.version
    helm_chart_version = local.version_tailscale_operator
  }
}

unit "tailscale_connector" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/connector"
  path   = "eks/addons/tailscale/connector"

  values = {
    version = local.version
  }
}

unit "tailscale_split_dns" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/split_dns"
  path   = "eks/addons/tailscale/split_dns"

  values = {
    version = local.version
  }
}

unit "argocd_app_of_apps" {
  source = "${get_repo_root()}/units/eks/addons/argocd/app_of_apps"
  path   = "eks/addons/argocd/app_of_apps"

  values = {
    version               = local.version
    name                  = "app-of-apps"
    namespace             = "argocd"
    path                  = "apps"
    target_revision       = "main"
    project               = "default"
    destination_namespace = "argocd"
    destination_server    = "https://kubernetes.default.svc"
    finalizers            = ["resources-finalizer.argocd.argoproj.io"]
    sync_options          = ["CreateNamespace=true"]
    prune                 = true
  }
}