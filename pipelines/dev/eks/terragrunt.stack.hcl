locals {
  version         = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  aws_lbc_version = "3.2.1"

  environment = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
  vpc_cidrs   = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs
  vpc_cidr    = local.vpc_cidrs[local.environment]

  private_subnets = [cidrsubnet(local.vpc_cidr, 8, 1), cidrsubnet(local.vpc_cidr, 8, 2)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 8, 3), cidrsubnet(local.vpc_cidr, 8, 4)]
}

unit "route53_hosted_zone_public" {
  source = "${get_repo_root()}/units/eks/route53/hosted_zone_public"
  path   = "eks/route53/hosted_zone_public"

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
    version    = "6.6.0"

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
    version = "21.15.1"

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
    url     = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${local.aws_lbc_version}/docs/install/iam_policy.json"
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
    helm_chart_version          = local.aws_lbc_version
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
    helm_chart_version = "9.5.0"
    helm_values = {
      configs = {
        params = {
          "server.insecure"        = true
          "application.namespaces" = "*"
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

unit "argocd_server_cluster_role" {
  source = "${get_repo_root()}/units/eks/addons/argocd/rbac/server/cluster_role"
  path   = "eks/addons/argocd/rbac/server/cluster_role"
  values = { version = local.version }
}

unit "argocd_server_cluster_role_binding" {
  source = "${get_repo_root()}/units/eks/addons/argocd/rbac/server/cluster_role_binding"
  path   = "eks/addons/argocd/rbac/server/cluster_role_binding"
  values = { version = local.version }
}

unit "argocd_notifications_cluster_role" {
  source = "${get_repo_root()}/units/eks/addons/argocd/rbac/notifications/cluster_role"
  path   = "eks/addons/argocd/rbac/notifications/cluster_role"
  values = { version = local.version }
}

unit "argocd_notifications_cluster_role_binding" {
  source = "${get_repo_root()}/units/eks/addons/argocd/rbac/notifications/cluster_role_binding"
  path   = "eks/addons/argocd/rbac/notifications/cluster_role_binding"
  values = { version = local.version }
}

unit "route53_hosted_zone_private" {
  source = "${get_repo_root()}/units/eks/route53/hosted_zone_private"
  path   = "eks/route53/hosted_zone_private"

  values = {
    version = local.version
    comment = "Managed by Terraform"
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
    helm_chart_version = "1.20.0"
    helm_values = {
      sources = ["service", "ingress"]
      provider = {
        name = "aws"
      }
      registry = "txt"
      policy   = "sync"
      logLevel = "info"
      extraArgs = {
        "aws-zone-type" = "private"
      }
    }
  }
}

unit "acm_certificate" {
  source = "${get_repo_root()}/units/eks/acm_certificate"
  path   = "eks/acm_certificate"

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
    helm_chart_version = "2.4.1"
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
    helm_chart_version = "1.96.5"
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