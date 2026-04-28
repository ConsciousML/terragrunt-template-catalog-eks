locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
}

unit "route53_hosted_zone" {
  source = "${get_repo_root()}/units/eks/route53_hosted_zone"
  path   = "eks/route53_hosted_zone"

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
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

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
  }
}

unit "iam_role_aws_lbc" {
  source = "${get_repo_root()}/units/eks/addons/iam_role_aws_lbc"
  path   = "eks/addons/iam_role_aws_lbc"

  values = {
    version         = local.version
    iam_policy_name = "aws-load-balancer-controller-policy"
    iam_policy_url  = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v3.2.1/docs/install/iam_policy.json"
    iam_role_name   = "aws-load-balancer-controller"
    tags            = {}
  }
}

unit "aws_load_balancer_controller" {
  source = "${get_repo_root()}/units/eks/addons/aws_load_balancer_controller"
  path   = "eks/addons/aws_load_balancer_controller"

  values = {
    version            = local.version
    helm_chart_version = "3.2.1"
  }
}

unit "argocd" {
  source = "${get_repo_root()}/units/eks/addons/argocd"
  path   = "eks/addons/argocd"

  values = {
    version            = local.version
    helm_chart_version = "9.5.0"
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

unit "route53_hosted_zone_private" {
  source = "${get_repo_root()}/units/eks/route53_hosted_zone_private"
  path   = "eks/route53_hosted_zone_private"

  values = {
    version = local.version
    comment = "Managed by Terraform"
  }
}

unit "iam_role_external_dns" {
  source = "${get_repo_root()}/units/eks/addons/iam_role_external_dns"
  path   = "eks/addons/iam_role_external_dns"

  values = {
    version         = local.version
    iam_policy_name = "external-dns-policy"
    iam_role_name   = "external-dns"
    tags            = {}
  }
}

unit "external_dns" {
  source = "${get_repo_root()}/units/eks/addons/external_dns"
  path   = "eks/addons/external_dns"

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