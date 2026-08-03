# Monitoring

What an operator needs to know about the deployed [`kube-prometheus-stack`](../units/eks/addons/prometheus_stack/README.md): what's running, how to reach it, and which tool to use for what.

The Helm release is configured in the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template)'s [`helm-kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-kube-prometheus-stack/values.yaml). Implementation details below link there.

## Prerequisites

- All [bootstrap pipelines](../pipelines/bootstrap/README.md) have been run
- The [Tailscale client](../pipelines/bootstrap/tailscale/README.md#prerequisites) is installed and connected (every UI here is private)
- The [EKS stack](../units/eks/README.md) is deployed, in any environment (`dev`, `staging`, `prod`)

URLs below use `<environment>` and `<base_domain>` as placeholders, e.g. `prometheus.private.dev.axelmendoza.com` for `dev` with `base_domain = axelmendoza.com` (see [`pipelines/dns.hcl`](../pipelines/dns.hcl)).

## What's Deployed

- **[Prometheus](https://prometheus.io/docs/introduction/overview/)**: scrapes and stores metrics
- **[Prometheus Operator](https://prometheus-operator.dev/)**: manages Prometheus and Alertmanager via `ServiceMonitor`, `PodMonitor`, and `PrometheusRule` CRDs
- **[Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)**: routes and dedupes firing alerts, sends them to Slack
- **[Grafana](https://grafana.com/docs/grafana/latest/)**: dashboards and Explore over the Prometheus and Loki datasources
- **[Loki](https://grafana.com/docs/loki/latest/)**: log aggregation and storage, backed by S3
- **[Alloy](https://grafana.com/docs/alloy/latest/)**: ships pod logs and Kubernetes cluster events to Loki
- **[kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)**: exposes cluster object state (Deployments, Pods, Nodes, ...) as metrics
- **[node-exporter](https://github.com/prometheus/node_exporter)**: exposes host-level metrics (CPU, memory, disk, network) per node

## Accessing the UIs

| UI | URL | Use it for |
|---|---|---|
| Grafana | `https://grafana.private.<environment>.<base_domain>` | Dashboards over node, pod, and addon metrics |
| Prometheus | `https://prometheus.private.<environment>.<base_domain>` | Ad-hoc PromQL queries, checking target/scrape health |
| Alertmanager | `https://alertmanager.private.<environment>.<base_domain>` | Viewing and silencing firing alerts |
| Slack | Your Slack workspace, [base channel names listed here](../pipelines/bootstrap/slack/channels.hcl), each prefixed with the environment (e.g. `#dev-k8s-critical`) | Receiving alert notifications |

### Grafana Login

Username is `admin`. Retrieve the password with:
```bash
aws secretsmanager get-secret-value \
  --secret-id <environment>-grafana-password \
  --query SecretString \
  --output text | jq -r .plaintext
```

## Which Tool to Reach For

- **Control plane health** (API server, scheduler, controller manager, etcd): [EKS Observability dashboard](https://docs.aws.amazon.com/eks/latest/userguide/eks-observe.html) in the AWS Console
- **Raw control plane metrics**, to query one directly: [`metrics.eks.amazonaws.com`](https://docs.aws.amazon.com/eks/latest/userguide/view-raw-metrics.html)
- **Node, pod, workload, and addon-level metrics** (ArgoCD, ExternalDNS, ESO, Karpenter): Grafana
- **Pod logs and Kubernetes cluster events**: Grafana Explore, Loki datasource
- **Viewing and silencing firing alerts**: Alertmanager
- **Alert notifications**: Slack

### How to Browse Logs

Open [Grafana](#accessing-the-uis), go to **Explore**, and select the **Loki** datasource. See Grafana's [Explore](https://grafana.com/docs/grafana/latest/explore/) docs and Loki's [LogQL](https://grafana.com/docs/loki/latest/query/) docs for query syntax.

Labels available on every stream are set in [`helm-alloy/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-alloy/values.yaml)'s `discovery.relabel` and `loki.process` blocks.

## Monitoring a New Component

Prometheus is configured with `serviceMonitorSelectorNilUsesHelmValues: false` and `podMonitorSelectorNilUsesHelmValues: false` (see [`helm-kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-kube-prometheus-stack/values.yaml)), so it picks up any [`ServiceMonitor`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.ServiceMonitor) or [`PodMonitor`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMonitor) in the cluster regardless of label. To scrape a new addon, add one alongside it rather than editing that Helm values file.

To alert on a new metric, add a [`PrometheusRule`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PrometheusRule) the same way.

## Alerting

Alertmanager posts to Slack.

Routing is by `component` (`k8s` or `prometheus-stack`, set per rule group via `defaultRules.additionalRuleGroupLabels` in [`helm-kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-kube-prometheus-stack/values.yaml)), then by `severity` (`warning` or `critical`), each combination landing in its own channel. `Watchdog` gets its own channel instead, confirming the pipeline is alive.

Anything matching neither a known `component` nor `Watchdog` falls into `#<environment>-unrouted` instead of mixing silently into `#<environment>-prometheus-stack-warning`, so a gap in the routing tree stays visible. Alerts with `severity: info` or `severity: none` (other than `Watchdog`) aren't sent to Slack. Resolved alerts post a follow-up notification in the same channel.

Base channel names are listed in [`pipelines/bootstrap/slack/channels.hcl`](../pipelines/bootstrap/slack/channels.hcl), each prefixed with the environment name so one shared Slack bot can post every environment's alerts without colliding. Channels are created per environment via the [Slack bootstrap](../pipelines/bootstrap/slack/README.md)'s `channels` pipeline.

## Dev-only Deviations

- `KubeCPUOvercommit` is disabled (see [`helm-kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-kube-prometheus-stack/values.yaml)). The `dev` node group intentionally runs 2 nodes, and the rule can't tell EKS has no control-plane node label, so it always fails N+1 tolerance on a cluster this size. Don't carry this disable over to `staging` or `prod`, where N+1 node failure tolerance is a real concern the rule should keep catching.
