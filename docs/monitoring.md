# Monitoring

What an operator needs to know about the [`kube-prometheus-stack`](../units/eks/addons/prometheus_stack/README.md) deployment: what's running, how to reach it, and which tool to use for what.

## Prerequisites

- All [bootstrap pipelines](../pipelines/bootstrap/README.md) have been run
- The [Tailscale client](../pipelines/bootstrap/tailscale/README.md#prerequisites) is installed and connected (every UI here is private)
- The [EKS stack](../units/eks/README.md) is deployed, in any environment (`dev`, `staging`, `prod`)

URLs below use `<environment>` and `<base_domain>` as placeholders, e.g. `prometheus.private.dev.axelmendoza.com` for the `dev` environment with `base_domain = axelmendoza.com` (see [`pipelines/dns.hcl`](../pipelines/dns.hcl)).

## What's Deployed

- **[Prometheus](https://prometheus.io/docs/introduction/overview/)**: scrapes and stores metrics
- **[Prometheus Operator](https://prometheus-operator.dev/)**: manages Prometheus/Alertmanager via `ServiceMonitor`, `PodMonitor`, and `PrometheusRule` CRDs
- **[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)**: routes and dedupes firing alerts
- **[Grafana](https://grafana.com/docs/grafana/latest/)**: dashboards over the Prometheus datasource
- **[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)**: exposes cluster object state (Deployments, Pods, Nodes, ...) as metrics
- **[node-exporter](https://github.com/prometheus/node_exporter)**: exposes host-level metrics (CPU, memory, disk, network) per node

## Accessing the UIs

| UI | URL | Use it for |
|---|---|---|
| Grafana | `https://grafana.private.<environment>.<base_domain>` | Dashboards over node, pod, and addon metrics |
| Prometheus | `https://prometheus.private.<environment>.<base_domain>` | Ad-hoc PromQL queries, checking target/scrape health |
| Alertmanager | `https://alertmanager.private.<environment>.<base_domain>` | Viewing and silencing firing alerts |

### Grafana login

Username is `admin`. The password is generated in AWS Secrets Manager and synced into the cluster via the External Secrets Operator. Retrieve it with:
```bash
aws secretsmanager get-secret-value \
  --secret-id <environment>-grafana-password \
  --query SecretString \
  --output text | jq -r .plaintext
```
See [`prometheus_stack/grafana`](../units/eks/addons/prometheus_stack/README.md#whats-inside) for how the password is generated (`aws_secret_password`) and synced into the cluster (`aws_external_secret`).

## Which Tool to Reach For

- **Control plane health** (API server, scheduler, controller manager, etcd): [EKS Observability dashboard](https://docs.aws.amazon.com/eks/latest/userguide/eks-observe.html) in the AWS Console
- **Raw control plane metrics**, when you need to query a specific one directly: [`metrics.eks.amazonaws.com`](https://docs.aws.amazon.com/eks/latest/userguide/view-raw-metrics.html)
- **Node, pod, workload, and addon-level metrics** (ArgoCD, ExternalDNS, ESO, Karpenter): Grafana
- **Alerting**: Alertmanager

## Monitoring a New Component

Prometheus is configured with `serviceMonitorSelectorNilUsesHelmValues: false` and `podMonitorSelectorNilUsesHelmValues: false` (see [`prometheus_stack/helm`](../units/eks/addons/prometheus_stack/helm/)), so it picks up any [`ServiceMonitor`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.ServiceMonitor) or [`PodMonitor`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMonitor) in the cluster regardless of label. To scrape a new addon, add one alongside it rather than editing this stack's Helm values.

To alert on a new metric, add a [`PrometheusRule`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PrometheusRule) the same way.

## Configuring Alert Targets

TODO: Alertmanager currently ships with the chart's default receiver (no-op). Configure a real receiver (Slack, PagerDuty, email, ...) before relying on alerting in `staging`/`prod`.

## Dev-only Deviations

- `KubeCPUOvercommit` is disabled (see [`prometheus_stack/helm`](../units/eks/addons/prometheus_stack/helm/)). The `dev` node group intentionally runs 2 nodes, and the rule can't tell EKS has no control-plane node label, so it always fails N+1 tolerance on a cluster this size. Don't carry this disable over to `staging`/`prod`, where N+1 node failure tolerance is a real concern the rule should keep catching.
