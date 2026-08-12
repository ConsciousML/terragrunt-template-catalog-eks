# EKS Cluster Stack

A prod-ready [stack](../../stacks/README.md) of [units](../README.md) for deploying EKS clusters across `dev`, `staging`, and `prod`.

The cluster supports:

- Persistent storage via EBS-backed `PersistentVolumeClaim`s
- Cluster and workload metrics via Prometheus, Alertmanager, and Grafana
- Workload resource-sizing recommendations via the VPA recommender and Goldilocks
- Log aggregation via Loki
- Public and private traffic routing via ALB and Gateway API
- Automated DNS and TLS termination
- Secrets synced from AWS Secrets Manager
- GitOps via ArgoCD and the App of Apps pattern
- VPN access via Tailscale
- Node autoscaling via Karpenter
- Pod-to-pod network flow visibility via Cilium and Hubble

## How to Use

The following pipelines must run once before deploying this stack:

- **[AWS GitHub Actions Auth](../../pipelines/bootstrap/aws_gh_actions_auth/README.md)**: provisions the OIDC provider, IAM role, and GitHub secrets for CI to deploy this stack
- **[Setup DNS](../../pipelines/bootstrap/setup_dns/README.md)**: creates the public Route53 hosted zone and delegates it at the registrar. The EKS stack assumes the zone exists and sets `create = false`
- **[Tailscale](../../pipelines/bootstrap/tailscale/README.md)**: provisions the ACL policy and WIF credential so CI can authenticate to Tailscale when deploying the operator

This stack is instantiated in:

- **[`pipelines/dev/eks/stack`](../../pipelines/dev/eks/stack/)**: local development environment for iterating on catalog changes
- **[`live/prod/eks`](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/live/prod/eks)**: production environment in the live repository
- **[`live/staging/eks`](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/live/staging/eks)**: staging environment in the live repository

## What's Inside

- **[cluster](cluster/)**: EKS control plane and managed node groups
- **[route53](route53/README.md)**: public and private hosted zones and wildcard ACM certificate
- **[addons/ebs_csi_driver](addons/ebs_csi_driver/README.md)**: EKS managed addon providing `PersistentVolumeClaim` provisioning backed by EBS volumes
- **[addons/prometheus_stack](addons/prometheus_stack/README.md)**: cluster and workload metrics via Prometheus, Alertmanager, and Grafana
- **[addons/aws_load_balancer_controller](addons/aws_load_balancer_controller/README.md)**: provisions ALBs from `Ingress` and `Gateway` resources
- **[addons/external_dns](addons/external_dns/README.md)**: syncs DNS records for cluster services to the private and public hosted zones
- **[addons/external_secrets_operator](addons/external_secrets_operator/README.md)**: syncs secrets from AWS Secrets Manager into Kubernetes `Secret` objects
- **[addons/loki](addons/loki/README.md)**: cluster-wide log aggregation backed by S3
- **[addons/argocd](addons/argocd/README.md)**: GitOps controller for declarative application delivery
- **[addons/argocd/app_of_apps](addons/argocd/app_of_apps/)**: deploys the root ArgoCD `Application` that bootstraps all child apps from the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template)
- **[addons/tailscale](addons/tailscale/README.md)**: VPN access to internal cluster services via subnet routing and split DNS
- **[addons/karpenter](addons/karpenter/README.md)**: node autoscaler provisioning EC2 instances on demand
- **[domain_name](domain_name/README.md)**: exposes each user-facing tool's domain name as a Terraform state output for the live repository's Terratest suite
- **[`priority-classes`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/manifests/priority-classes)** (app-of-apps): `PriorityClass` for cluster-wide DaemonSets that need to land on every node
- **[`crds-gateway-api`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/manifests/crds/gateway-api)**, **[`crds-aws-lbc-gateway-api`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/manifests/crds/aws-lbc-gateway-api)**, **[`gateway-class`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/gateway-api/gateway-class)** (app-of-apps): Gateway API CRDs and the `GatewayClass` implemented by the AWS Load Balancer Controller, backing the `gateway-public` and `gateway-private` Gateways
- **[`vpa`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/right-sizing/vpa)**, **[`goldilocks`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/right-sizing/goldilocks)** (app-of-apps): workload resource-sizing recommendations, see the [right-sizing guide](../../docs/right-sizing.md)
- **[`podinfo`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/manifests/podinfo)** (app-of-apps): sample app used to verify an end-to-end deploy, meant to be swapped for a real app in a fork
- **[`cilium`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/cilium)**, **[`hubble-ui-httproute`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/gateway-api/httproute)** (app-of-apps): Cilium in CNI chaining mode alongside `vpc-cni` (no change to existing networking behavior), providing Hubble network flow visibility for audits

## Dependency Graph

From the root of this repository, cd into the dev stack, generate it, then render the graph:

```bash
cd pipelines/dev/eks/stack
terragrunt stack generate
terragrunt dag graph | dot -Tpng > /tmp/graph.png && open /tmp/graph.png
```
