# Monitoring

What an operator needs to know about the deployed [`kube-prometheus-stack`](../units/eks/addons/prometheus_stack/README.md): what's running, how to reach it, and which tool to use for what.

The Helm release is configured in the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template)'s [`charts/monitoring/kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/kube-prometheus-stack/values.yaml). Implementation details below link there.

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
- **[blackbox-exporter](https://github.com/prometheus/blackbox_exporter)**: probes every private and public tool endpoint for HTTP reachability

## Accessing the UIs

| UI | URL | Use it for |
|---|---|---|
| Grafana | `https://grafana.private.<environment>.<base_domain>` | Dashboards over node, pod, and addon metrics |
| Prometheus | `https://prometheus.private.<environment>.<base_domain>` | Ad-hoc PromQL queries, checking target/scrape health |
| Alertmanager | `https://alertmanager.private.<environment>.<base_domain>` | Viewing and silencing firing alerts |
| Hubble UI | `https://hubble.private.<environment>.<base_domain>` | Visualizing live and historical pod-to-pod network flows |
| Slack | Your Slack workspace, [base channel names listed here](../pipelines/bootstrap/slack/channels.hcl), each prefixed with the environment (e.g. `#dev-k8s-critical`) | Receiving alert notifications |

### Grafana Login

Username is `admin`. Retrieve the password with:
```bash
aws secretsmanager get-secret-value \
  --secret-id <environment>-grafana-password \
  --query SecretString \
  --output text | jq -r .plaintext
```

## Network Observability (Hubble)

[Cilium](https://cilium.io/) runs in [CNI chaining mode](https://docs.cilium.io/en/stable/installation/cni-chaining/) alongside the `vpc-cni` EKS addon, for flow visibility and `NetworkPolicy` enforcement. Configuration lives in the App of Apps repo's [`charts/cilium/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/cilium/values.yaml).

[Hubble](https://docs.cilium.io/en/stable/observability/hubble/) shows, per flow, who talked to whom, over what protocol, and whether it was allowed or dropped, useful for auditing traffic without guessing at a `NetworkPolicy`. No login, access is restricted via Tailscale like every other private UI here.

See [Network Policies](network-policies.md) for how to use Hubble to write and harden a `CiliumNetworkPolicy`.

Cilium, Hubble, and their Grafana dashboards are provisioned the same way as every other addon (see [Monitoring a New Component](#monitoring-a-new-component) below), no extra wiring needed to see them in Grafana.

### Hubble CLI

To query flows from a terminal instead of the UI, observe at the namespace level:
```bash
hubble observe --namespace external-dns -P
```

Or at the pod level:
```bash
hubble observe --pod external-dns-private-7cb844c9d5-q8tns --namespace external-dns -P
```

See the [Hubble CLI docs](https://docs.cilium.io/en/latest/observability/hubble/hubble-cli/) for more.

### Restoring Full Flow Visibility

Cilium only manages pods created after `cilium-agent` is already running on their node, so every pod predating it (the entire EKS bootstrap) has no `CiliumEndpoint` and stays invisible to Hubble.

By default this is handled automatically: `argocd-app-of-apps-template`'s [`manifests/cilium-restart-job`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/manifests/cilium-restart-job) runs a one-shot `Job` right after Cilium syncs, restarting every bootstrap-time pod.

If a pod is still missing one afterward, fix it with [`scripts/restart-missing-cilium-endpoints.sh`](../scripts/restart-missing-cilium-endpoints.sh), see [Cilium's restart-existing-pods guidance](https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/#restart-existing-pods). It logs what it finds missing before restarting it, waits for each rollout, then re-scans and fails if anything is still missing.

**Warning**: restarting deletes and recreates pods. Run only during a maintenance window:
```bash
scripts/restart-missing-cilium-endpoints.sh
```

Same script as the one baked into the Job's `ConfigMap`, kept in sync manually.

To avoid this altogether, install Cilium in [ENI mode](https://cilium.io/blog/2025/06/19/eks-eni-install/) instead of chained: a bigger change (it replaces `vpc-cni` instead of sitting alongside it), but kubelet then waits on Cilium's own CNI config, closing the gap.

## Which Tool to Reach For

- **Control plane health** (API server, scheduler, controller manager, etcd): [EKS Observability dashboard](https://docs.aws.amazon.com/eks/latest/userguide/eks-observe.html) in the AWS Console
- **Raw control plane metrics**, to query one directly: [`metrics.eks.amazonaws.com`](https://docs.aws.amazon.com/eks/latest/userguide/view-raw-metrics.html)
- **Node, pod, workload, and addon-level metrics** (ArgoCD, ExternalDNS, ESO, Karpenter): Grafana
- **Pod-to-pod network flows** (who talked to whom, allowed or denied, by protocol): Hubble UI
- **Pod logs and Kubernetes cluster events**: Grafana Explore, Loki datasource
- **Viewing and silencing firing alerts**: Alertmanager
- **Alert notifications**: Slack

### How to Browse Logs

Open [Grafana](#accessing-the-uis), go to **Explore**, and select the **Loki** datasource. See Grafana's [Explore](https://grafana.com/docs/grafana/latest/explore/) docs and Loki's [LogQL](https://grafana.com/docs/loki/latest/query/) docs for query syntax.

Labels available on every stream are set in [`charts/monitoring/alloy/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/alloy/values.yaml)'s `discovery.relabel` and `loki.process` blocks.

## Monitoring a New Component

Prometheus is configured with `serviceMonitorSelectorNilUsesHelmValues: false` and `podMonitorSelectorNilUsesHelmValues: false` (see [`charts/monitoring/kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/kube-prometheus-stack/values.yaml)), so it picks up any [`ServiceMonitor`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.ServiceMonitor) or [`PodMonitor`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PodMonitor) in the cluster regardless of label. To scrape a new addon, add one alongside it rather than editing that Helm values file.

To alert on a new metric, add a [`PrometheusRule`](https://prometheus-operator.dev/docs/api-reference/api/#monitoring.coreos.com/v1.PrometheusRule) the same way.

## Alerting

Alertmanager posts to Slack.

Routing is by `component` (`k8s`, `prometheus-stack`, `loki`, `argocd`, or `uptime`), then by `severity` (`warning` or `critical`), each combination landing in its own channel. The `component` label is attached one of two ways:

- Chart-bundled rules (kube-prometheus-stack's own, Loki's mixin): via a Helm value, e.g. `defaultRules.additionalRuleGroupLabels` or `loki.monitoring.alerts.additionalRuleLabels` in [`charts/monitoring/kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/kube-prometheus-stack/values.yaml) and [`charts/monitoring/loki/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/loki/values.yaml)
- Standalone `PrometheusRule` manifests, or a chart's own `prometheusRule.rules` value (blackbox-exporter's): directly on each alert's `labels`, see [`prometheus-rules`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/monitoring/prometheus-rules) and [`charts/monitoring/blackbox-exporter/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/blackbox-exporter/values.yaml)

`Watchdog` gets its own channel instead, confirming the pipeline is alive.

Anything matching neither a known `component` nor `Watchdog` falls into `#<environment>-unrouted` instead of mixing silently into `#<environment>-prometheus-stack-warning`, so a gap in the routing tree stays visible. Alerts with `severity: info` or `severity: none` (other than `Watchdog`) aren't sent to Slack. Resolved alerts post a follow-up notification in the same channel.

Base channel names are listed in [`pipelines/bootstrap/slack/channels.hcl`](../pipelines/bootstrap/slack/channels.hcl), each prefixed with the environment name so one shared Slack bot can post every environment's alerts without colliding. Channels are created per environment via the [Slack bootstrap](../pipelines/bootstrap/slack/README.md)'s `channels` pipeline.

## Dev-only Deviations

- `KubeCPUOvercommit` is disabled (see [`charts/monitoring/kube-prometheus-stack/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/kube-prometheus-stack/values.yaml)). The `dev` node group intentionally runs 2 nodes, and the rule can't tell EKS has no control-plane node label, so it always fails N+1 tolerance on a cluster this size. Don't carry this disable over to `staging` or `prod`, where N+1 node failure tolerance is a real concern the rule should keep catching.
