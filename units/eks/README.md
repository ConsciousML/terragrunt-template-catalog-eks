# EKS Cluster Stack

A prod-ready Terragrunt catalog of building blocks for deploying EKS clusters across `dev`, `staging`, and `prod`.

The cluster comes with:

- GitOps via ArgoCD and the App of Apps pattern
- Public traffic routing via ALB and Gateway API
- Automated DNS and TLS termination
- VPN access via Tailscale
- Node autoscaling via Karpenter

## Bootstrap Prerequisites

The following pipelines must run once before deploying this stack:

- **[AWS GitHub Actions Auth](../../pipelines/bootstrap/aws_gh_actions_auth/README.md)**: provisions the OIDC provider, IAM role, and GitHub secrets for CI to deploy this stack
- **[Setup DNS](../../pipelines/bootstrap/setup_dns/README.md)**: creates the public Route53 hosted zone and delegates it at the registrar. The EKS stack assumes the zone exists and sets `create = false`
- **[Tailscale](../../pipelines/bootstrap/tailscale/README.md)**: provisions the ACL policy and WIF credential so CI can authenticate to Tailscale when deploying the operator

## What's Inside

- **[cluster](cluster/)**: EKS control plane and managed node groups
- **[route53](route53/README.md)**: public and private hosted zones and wildcard ACM certificate
- **[addons/aws_load_balancer_controller](addons/aws_load_balancer_controller/README.md)**: provisions ALBs from `Ingress` and `Gateway` resources
- **[addons/gateway_api](addons/gateway_api/README.md)**: shared internet-facing ALB with TLS, routing owned by each app's `HTTPRoute`
- **[addons/external_dns](addons/external_dns/README.md)**: two instances syncing DNS records to the private and public hosted zones
- **[addons/external_secrets_operator](addons/external_secrets_operator/README.md)**: operator that syncs secrets from AWS Secrets Manager into Kubernetes `Secret` objects, used here to inject the ArgoCD admin password into the cluster
- **[addons/argocd](addons/argocd/README.md)**: GitOps controller with admin password managed via ESO
- **[addons/argocd/app_of_apps](addons/argocd/app_of_apps/)**: deploys the root ArgoCD `Application` that bootstraps all child apps from the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template)
- **[addons/tailscale](addons/tailscale/README.md)**: VPN access to internal cluster services via subnet routing and split DNS
- **[addons/karpenter](addons/karpenter/README.md)**: node autoscaler provisioning EC2 instances on demand

> **Note**: Karpenter's NodePool is capped at 10 vCPUs by default. Raise `spec.limits.cpu` in the [EKS stack](../../pipelines/dev/eks/stack/terragrunt.stack.hcl) before deploying if your workloads require more capacity.

## Dependency Graph

From the root of this repository, cd into the dev stack, generate it, then render the graph:

```bash
cd pipelines/dev/eks/stack
terragrunt stack generate
terragrunt dag graph | dot -Tpng > /tmp/graph.png && open /tmp/graph.png
```

## Multi-environment Infrastructure

This stack is instantiated in:

- **[`pipelines/dev/eks/stack`](../../pipelines/dev/eks/stack/)**: local development environment for iterating on catalog changes
- **[`live/prod/eks`](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/live/prod/eks)**: production environment in the live repository
- **[`live/staging/eks`](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/live/staging/eks)**: staging environment in the live repository
