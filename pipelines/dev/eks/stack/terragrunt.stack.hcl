locals {
  version         = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  version_vpc     = "6.6.0"
  version_cluster = "21.15.1"
  # Keep in sync with the aws-load-balancer-controller chart dependency version pinned in
  # the app-of-apps repo's aws-load-balancer-controller/Chart.yaml
  version_aws_lbc        = "3.2.1"
  version_argocd         = "9.5.0"
  version_argocd_apps    = "2.0.5"
  version_karpenter_iam  = "21.24.0"
  version_karpenter_helm = "1.14.0"
  # Keep in sync with the appVersion the kube-prometheus-stack chart dependency pins in the
  # app-of-apps repo's helm-kube-prometheus-stack/Chart.yaml, both track the same
  # prometheus-operator CRD version.
  version_prometheus_operator_crds = "30.0.1"
  version_s3                       = "5.15.1"

  environment       = read_terragrunt_config(find_in_parent_folders("environment.hcl")).locals.environment
  cluster_name_full = read_terragrunt_config(find_in_parent_folders("cluster_name_env.hcl")).locals.cluster_name_full
  vpc_cidrs         = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs
  vpc_cidr          = local.vpc_cidrs[local.environment]

  # /19 each (8,187 usable IPs), sized for prefix delegation. Indices 2 and 5 skipped,
  # reserved for a future 3rd AZ pair.
  private_subnets = [cidrsubnet(local.vpc_cidr, 3, 0), cidrsubnet(local.vpc_cidr, 3, 1)]
  public_subnets  = [cidrsubnet(local.vpc_cidr, 3, 3), cidrsubnet(local.vpc_cidr, 3, 4)]

  # Shared by every Karpenter NodePool. Only capacity-type differs per pool.
  karpenter_node_pool_base_requirements = [
    {
      key      = "kubernetes.io/arch"
      operator = "In"
      values   = ["amd64"]
    },
    {
      key      = "kubernetes.io/os"
      operator = "In"
      values   = ["linux"]
    },
    # Diversify across instance families and sizes for deeper, cheaper spot pools.
    {
      key      = "karpenter.k8s.aws/instance-category"
      operator = "In"
      values   = ["c", "m", "r", "t"]
    },
    {
      key      = "karpenter.k8s.aws/instance-generation"
      operator = "Gt"
      values   = ["2"]
    },
    # Exclude oversized instances so Karpenter never bin-packs onto an expensive
    # instance. nano, micro, and small are too small to be useful: every node runs the same
    # fixed floor of DaemonSets (aws-node, kube-proxy, ebs-csi-node, eks-pod-identity-agent,
    # alloy, loki-canary) regardless of size, so provisioning more.
    # The instance-cpu and instance-memory requirements below raise the real
    # floor further: size labels are family-relative (a "medium" can be 1 vCPU in one family,
    # 2 in another).
    {
      key      = "karpenter.k8s.aws/instance-size"
      operator = "NotIn"
      values   = ["nano", "micro", "small", "metal"]
    },
    # >= 2 vCPU
    {
      key      = "karpenter.k8s.aws/instance-cpu"
      operator = "Gt"
      values   = ["1"]
    },
    # >= 4 Gb RAM
    {
      key      = "karpenter.k8s.aws/instance-memory"
      operator = "Gt"
      values   = ["4095"]
    }
  ]

  # Required onto the critical NodePool, no fallback to the MNG.
  critical_node_selector = {
    "karpenter.sh/nodepool" = "critical"
  }
  critical_tolerations = [
    {
      key      = "karpenter.sh/workload-class"
      operator = "Equal"
      value    = "critical"
      effect   = "NoSchedule"
    }
  ]

  # Required onto the MNG
  mng_node_selector = {
    "node-role/mng" = "true"
  }
  mng_tolerations = [
    {
      key      = "node-role/mng"
      operator = "Equal"
      value    = "true"
      effect   = "NoSchedule"
    }
  ]
}

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

    enable_flow_log                      = false
    create_flow_log_cloudwatch_log_group = false
    create_flow_log_cloudwatch_iam_role  = false

    flow_log_traffic_type             = "REJECT" # only denied traffic reduces log volume
    flow_log_max_aggregation_interval = 600      # 10-min batching vs 60s, fewer records

    # Cost optimization: cheaper CloudWatch log class + short retention
    flow_log_cloudwatch_log_group_class             = "INFREQUENT_ACCESS"
    flow_log_cloudwatch_log_group_retention_in_days = 7

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

    kubernetes_version = "1.36"

    # Two-phase bootstrap: keep public access on for the initial apply, since ArgoCD,
    # app-of-apps, and the Tailscale Connector (which gives CI its route into the VPC)
    # aren't up yet on a brand-new cluster. Once ArgoCD is reachable over Tailscale,
    # confirming the Connector is routing, set `endpoint_public_access` to false here
    # and re-apply the `cluster` unit. See docs/new-environment.md for the exact step.
    endpoint_public_access  = true
    endpoint_private_access = true

    # Adds the current caller identity as an administrator via cluster access entry
    enable_cluster_creator_admin_permissions = true

    control_plane_scaling_config = {
      tier = "standard"
    }

    # DEV: control plane logging disabled to cut CloudWatch costs, do not port this to
    # staging/prod, re-enable there. See
    # https://github.com/ConsciousML/terragrunt-template-live-eks/issues/40 for details.
    enabled_log_types = []
    # Infrequent Access cuts cost ~50% but doesn't support all Standard class features:
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CloudWatch_Logs_Log_Classes.html
    cloudwatch_log_group_class             = "INFREQUENT_ACCESS"
    cloudwatch_log_group_retention_in_days = 7

    # Run the following command to see all the available addons:
    # aws eks describe-addon-versions --query 'addons[*].addonName' --output text | tr '\t' '\n'
    # Here's the argument reference for the addons:
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
    # Read the following for additional information about the available addons:
    # https://docs.aws.amazon.com/eks/latest/userguide/workloads-add-ons-available-eks.html
    addons = {
      # aws-ebs-csi-driver is installed from units/eks/addons/ebs_csi_driver/addon
      coredns = {
        addon_version = "v1.14.2-eksbuild.4"
        configuration_values = jsonencode({
          resources = {
            requests = { cpu = "11m", memory = "24M" }
            limits   = { cpu = "55m", memory = "24M" }
          }
          tolerations = local.mng_tolerations
        })
      }
      eks-pod-identity-agent = {
        before_compute = true
        addon_version  = "v1.3.10-eksbuild.3"
        configuration_values = jsonencode({
          resources = {
            requests = { cpu = "11m", memory = "24M" }
            limits   = { cpu = "55m", memory = "24M" }
          }
        })
      }
      kube-proxy = {
        addon_version = "v1.36.0-eksbuild.7"
        configuration_values = jsonencode({
          resources = {
            requests = { cpu = "11m", memory = "37M" }
            limits   = { cpu = "55m", memory = "37M" }
          }
          # No tolerations key: this addon's configuration schema doesn't support one, and its
          # default manifest already tolerates everything.
        })
      }
      metrics-server = {
        addon_version = "v0.9.0-eksbuild.2"
        configuration_values = jsonencode({
          resources = {
            requests = { cpu = "11m", memory = "37M" }
            limits   = { cpu = "55m", memory = "37M" }
          }
          tolerations = local.mng_tolerations
        })
      }
      vpc-cni = {
        before_compute = true
        addon_version  = "v1.21.2-eksbuild.2"
        configuration_values = jsonencode({
          # Prefix delegation: nodes need more IPs than one-per-ENI allows
          env = {
            ENABLE_PREFIX_DELEGATION = "true"
          }
          # Enables enforcement of NetworkPolicy resources, without this they are accepted but ignored
          enableNetworkPolicy = "true"
          # aws-node container
          resources = {
            requests = { cpu = "11m", memory = "64M" }
            limits   = { cpu = "55m", memory = "64M" }
          }
          # aws-eks-nodeagent container, enabled by enableNetworkPolicy above
          nodeAgent = {
            resources = {
              requests = { cpu = "11m", memory = "164M" }
              limits   = { cpu = "55m", memory = "164M" }
            }
          }
        })
      }
    }

    eks_managed_node_groups = {
      "${local.environment}_ng" = {
        # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
        ami_type = "AL2023_x86_64_STANDARD"

        # Pin to a specific AMI release to prevent unintended rolling node replacements on every apply.
        # use_latest_ami_release_version defaults to true upstream, which silently ignores this pin.
        # Find available versions with:
        # aws ssm get-parameters-by-path --path /aws/service/eks/optimized-ami/1.36/amazon-linux-2023/x86_64/standard --query 'Parameters[].Name'
        use_latest_ami_release_version = false
        ami_release_version            = "1.36.2-20260709"

        instance_types = ["t3.medium"]

        # DEV: spot is dev-only, prod should use on-demand
        capacity_type = "ON_DEMAND"

        # Use at least `min_size = 2`
        min_size     = 2
        desired_size = 2
        max_size     = 10

        # Blocks pods from reaching instance metadata: pods sit at hop 2, only the node itself (hop 1) can get a token
        metadata_options = {
          http_tokens                 = "required"
          http_put_response_hop_limit = 1
          http_endpoint               = "enabled"
        }

        # Reserves the MNG for pods that tolerate it (Karpenter's controller).
        # The taint alone doesn't attract those pods, mng_node_selector also needs this label.
        labels = local.mng_node_selector

        taints = {
          mng = {
            key    = "node-role/mng"
            value  = "true"
            effect = "NO_SCHEDULE"
          }
        }
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
    version       = local.version
    addon_version = "v1.62.0-eksbuild.1"
    tags          = {}
    configuration_values = jsonencode({
      # Single resources block per pod, applied to every sidecar container in it
      controller = {
        resources = {
          requests = { cpu = "11m", memory = "24M" }
          limits   = { memory = "24M" }
        }
        tolerations = local.mng_tolerations
      }
      node = {
        resources = {
          requests = { cpu = "11m", memory = "24M" }
          limits   = { cpu = "11m", memory = "24M" }
        }
        tolerations = local.mng_tolerations
      }
    })
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

# --- External Secrets Operator ---
# Only the IAM/Pod Identity resources are Terraform-managed; the Helm release lives in
# app-of-apps.

unit "iam_role_eso" {
  source = "${get_repo_root()}/units/eks/addons/external_secrets_operator/iam_role"
  path   = "eks/addons/external_secrets_operator/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

# --- Loki ---
# Only the S3/Pod Identity resources are Terraform-managed. The Helm release lives in
# app-of-apps.

unit "loki_s3_chunks" {
  source = "${get_repo_root()}/units/eks/addons/loki/s3/chunks"
  path   = "eks/addons/loki/s3/chunks"

  values = {
    version = local.version_s3
    tags    = {}
    # DEV: allows this dev stack to be destroyed without manually emptying the bucket first,
    # set to false for prod.
    force_destroy = true
  }
}

unit "loki_s3_ruler" {
  source = "${get_repo_root()}/units/eks/addons/loki/s3/ruler"
  path   = "eks/addons/loki/s3/ruler"

  values = {
    version = local.version_s3
    tags    = {}
    # DEV: allows this dev stack to be destroyed without manually emptying the bucket first,
    # set to false for prod.
    force_destroy = true
  }
}

unit "iam_role_loki" {
  source = "${get_repo_root()}/units/eks/addons/loki/iam_role"
  path   = "eks/addons/loki/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

# --- Prometheus Operator CRDs ---
# Installed ahead of ArgoCD so the ServiceMonitor CRD already exists by the time anything
# renders one.

unit "prometheus_operator_crds" {
  source = "${get_repo_root()}/units/eks/addons/prometheus_stack/crds"
  path   = "eks/addons/prometheus_stack/crds"

  values = {
    version            = local.version
    helm_chart_version = local.version_prometheus_operator_crds
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
      # Scraped for the argo-cd-mixin dashboards (https://github.com/adinhodovic/argo-cd-mixin).
      controller = {
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
        resources = {
          requests = { cpu = "1388m", memory = "1471M" }
          limits   = { memory = "1471M" }
        }
        # Outranks the DaemonSets' daemonset-critical (argocd-app-of-apps-template's
        # priority-classes/), so it can no longer be preempted to make room for one of them
        # on a full node.
        priorityClassName = "system-node-critical"
        nodeSelector      = local.critical_node_selector
        tolerations       = local.critical_tolerations
      }
      repoServer = {
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
        resources = {
          requests = { cpu = "49m", memory = "717M" }
          limits   = { memory = "717M" }
        }
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
      notifications = {
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
        resources = {
          requests = { cpu = "11m", memory = "64M" }
          limits   = { cpu = "11m", memory = "64M" }
        }
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
      applicationSet = {
        resources = {
          requests = { cpu = "11m", memory = "64M" }
          limits   = { cpu = "11m", memory = "64M" }
        }
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
      server = {
        resources = {
          requests = { cpu = "11m", memory = "150M" }
          limits   = { cpu = "55m", memory = "150M" }
        }
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
      redis = {
        resources = {
          requests = { cpu = "11m", memory = "35M" }
          limits   = { cpu = "55m", memory = "35M" }
        }
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
      # Separate Job from `redis` itself (initializes its auth secret), doesn't inherit
      # redis's nodeSelector/tolerations, needs its own.
      redisSecretInit = {
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
      dex = {
        resources = {
          requests = { cpu = "11m", memory = "64M" }
          limits   = { cpu = "55m", memory = "64M" }
        }
        nodeSelector = local.critical_node_selector
        tolerations  = local.critical_tolerations
      }
    }
  }
}

unit "argocd_password" {
  source = "${get_repo_root()}/units/eks/addons/argocd/aws_secret_password"
  path   = "eks/addons/argocd/aws_secret_password"

  values = {
    version                 = local.version
    length                  = 16
    recovery_window_in_days = 0
    tags                    = {}
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
    #target_revision       = "main"
    target_revision       = "replace-guestbook-by-podinfo"
    project               = "default"
    destination_namespace = "argocd"
    destination_server    = "https://kubernetes.default.svc"
    finalizers            = ["resources-finalizer.argocd.argoproj.io"]
    sync_options          = ["CreateNamespace=true"]
    prune                 = true
    helm_chart_version    = local.version_argocd_apps
    retry = {
      limit = 7
      backoff = {
        duration     = "5s"
        factor       = 2
        max_duration = "2m"
      }
    }
  }
}

# --- AWS Load Balancer Controller ---
# Only the AWS-side IAM/Pod Identity resources are Terraform-managed; the Helm release
# lives in app-of-apps.

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

# --- ExternalDNS ---
# Only the AWS-side IAM/Pod Identity resources are Terraform-managed; the Helm releases
# live in app-of-apps.

unit "iam_role_external_dns_private" {
  source = "${get_repo_root()}/units/eks/addons/external_dns/private/iam_role"
  path   = "eks/addons/external_dns/private/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

unit "iam_role_external_dns_public" {
  source = "${get_repo_root()}/units/eks/addons/external_dns/public/iam_role"
  path   = "eks/addons/external_dns/public/iam_role"

  values = {
    version = local.version
    tags    = {}
  }
}

# --- Tailscale ---
# Only the Tailscale-API Terraform resources (OAuth client, split DNS) are managed here;
# the operator Helm release and Connector CRD live in app-of-apps. The ACL policy lives in
# the pipelines/bootstrap/tailscale stack, not the EKS stack.

unit "tailscale_oauth_client_tailscale_operator" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/oauth_client_tailscale_operator"
  path   = "eks/addons/tailscale/oauth_client_tailscale_operator"

  values = {
    version = local.version
  }
}

unit "tailscale_oauth_client_secret" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/oauth_client_secret"
  path   = "eks/addons/tailscale/oauth_client_secret"

  values = {
    version                 = local.version
    recovery_window_in_days = 0
    tags                    = {}
  }
}

unit "tailscale_split_dns_default" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/split_dns/default"
  path   = "eks/addons/tailscale/split_dns/default"

  values = {
    version = local.version
  }
}

unit "tailscale_split_dns_eks_endpoint" {
  source = "${get_repo_root()}/units/eks/addons/tailscale/split_dns/eks"
  path   = "eks/addons/tailscale/split_dns/eks"

  values = {
    version = local.version
  }
}

# --- Karpenter ---

unit "karpenter_iam" {
  source = "${get_repo_root()}/units/eks/addons/karpenter/iam"
  path   = "eks/addons/karpenter/iam"

  values = {
    version = local.version_karpenter_iam
    # Set to true when using `SPOT` instances
    enable_spot_termination = true
    tags                    = {}
  }
}

unit "karpenter_helm" {
  source = "${get_repo_root()}/units/eks/addons/karpenter/helm"
  path   = "eks/addons/karpenter/helm"

  values = {
    version            = local.version
    helm_chart_version = local.version_karpenter_helm
    helm_values = {
      settings = {
        enableZonalShift = false
      }
      controller = {
        resources = {
          requests = { cpu = "163m", memory = "297M" }
          limits   = { memory = "297M" }
        }
      }
      # Requires the ServiceMonitor CRD from prometheus_operator_crds.
      serviceMonitor = {
        enabled = true
      }
      nodeSelector = local.mng_node_selector
      tolerations  = local.mng_tolerations
    }
  }
}

unit "karpenter_ec2_node_class" {
  source = "${get_repo_root()}/units/eks/addons/karpenter/ec2_node_class"
  path   = "eks/addons/karpenter/ec2_node_class"

  values = {
    version   = local.version
    name      = "default"
    ami_alias = "al2023@latest"
    # Matches kubelet's own default (what the MNG's nodes already get). Without this, Karpenter
    # computes a lower ceiling from the plain per-ENI formula, blind to the VPC CNI addon's
    # ENABLE_PREFIX_DELEGATION setting, which starves small instance types of pod slots.
    kubelet_max_pods = 110
  }
}

unit "karpenter_node_pool_critical" {
  source = "${get_repo_root()}/units/eks/addons/karpenter/node_pool/critical"
  path   = "eks/addons/karpenter/node_pool/critical"

  values = {
    version = local.version
    name    = "critical"
    requirements = concat(
      [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          # DEV: spot is dev-only, prod should use on-demand for the critical NodePool.
          values = ["spot"]
        }
      ],
      local.karpenter_node_pool_base_requirements
    )
    taints = [
      {
        key    = "karpenter.sh/workload-class"
        value  = "critical"
        effect = "NoSchedule"
      }
    ]
    disruption = {
      consolidationPolicy = "Balanced"
      consolidateAfter    = "15m"
      budgets = [
        {
          nodes = "1"
        }
      ]
    }
    limits_cpu = "16"
    # Long enough for Loki/Prometheus/ArgoCD to shut down cleanly, short enough to bound how
    # long a blocking PDB can delay a drift-driven AMI/CVE patch.
    termination_grace_period = "30m"
    expire_after             = "720h"
  }
}

unit "karpenter_node_pool_elastic" {
  source = "${get_repo_root()}/units/eks/addons/karpenter/node_pool/elastic"
  path   = "eks/addons/karpenter/node_pool/elastic"

  values = {
    version = local.version
    name    = "elastic"
    requirements = concat(
      [
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["spot"]
        },
      ],
      local.karpenter_node_pool_base_requirements
    )
    taints = [
      {
        key    = "karpenter.sh/workload-class"
        value  = "elastic"
        effect = "NoSchedule"
      }
    ]
    disruption = {
      consolidationPolicy = "WhenEmptyOrUnderutilized"
      consolidateAfter    = "2m"
      budgets = [
        {
          nodes = "50%"
        }
      ]
    }
    limits_cpu = "16"
    # Bounds worst-case drain time for elastic workloads, which tolerate disruption well.
    termination_grace_period = "2m"
    expire_after             = "720h"
  }
}

# --- Prometheus stack ---
# Only the Grafana admin password and the Alertmanager Slack bot secret (both Secrets Manager)
# are Terraform-managed; the Helm release, HTTPRoutes, and SecretStore/ExternalSecret live in
# app-of-apps.

unit "grafana_password" {
  source = "${get_repo_root()}/units/eks/addons/prometheus_stack/grafana/aws_secret_password"
  path   = "eks/addons/prometheus_stack/grafana/aws_secret_password"

  values = {
    version                 = local.version
    length                  = 16
    recovery_window_in_days = 0
    tags                    = {}
  }
}

unit "alertmanager_slack_bot_secret" {
  source = "${get_repo_root()}/units/eks/addons/prometheus_stack/alertmanager/aws_secret_slack_bot"
  path   = "eks/addons/prometheus_stack/alertmanager/aws_secret_slack_bot"

  values = {
    version                 = local.version
    bot_token               = get_env("SLACK_BOT_TOKEN")
    recovery_window_in_days = 0
    tags                    = {}
  }
}

# --- Domain names ---

unit "domain_name_argocd" {
  source = "${get_repo_root()}/units/eks/domain_name/argocd"
  path   = "eks/domain_name/argocd"

  values = {
    version = local.version
  }
}

unit "domain_name_podinfo" {
  source = "${get_repo_root()}/units/eks/domain_name/podinfo"
  path   = "eks/domain_name/podinfo"

  values = {
    version = local.version
  }
}

unit "domain_name_prometheus" {
  source = "${get_repo_root()}/units/eks/domain_name/prometheus"
  path   = "eks/domain_name/prometheus"

  values = {
    version = local.version
  }
}

unit "domain_name_alertmanager" {
  source = "${get_repo_root()}/units/eks/domain_name/alertmanager"
  path   = "eks/domain_name/alertmanager"

  values = {
    version = local.version
  }
}

unit "domain_name_grafana" {
  source = "${get_repo_root()}/units/eks/domain_name/grafana"
  path   = "eks/domain_name/grafana"

  values = {
    version = local.version
  }
}

unit "domain_name_goldilocks" {
  source = "${get_repo_root()}/units/eks/domain_name/goldilocks"
  path   = "eks/domain_name/goldilocks"

  values = {
    version = local.version
  }
}
