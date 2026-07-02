# kube-prometheus-stack

Deploys [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster and workload metrics: Prometheus, Alertmanager, Grafana, kube-state-metrics, and node-exporter.

## Concepts

- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Prometheus Operator](https://prometheus-operator.dev/)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Grafana](https://grafana.com/docs/grafana/latest/)
- [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [node-exporter](https://github.com/prometheus/node_exporter)

## What's Inside

- **[helm](helm/)**: Deploys the chart into the `monitoring` namespace, with `fullnameOverride` pinned so Service names are deterministic
- **[httproute](httproute/)**: One `HTTPRoute` per UI (Prometheus, Alertmanager, Grafana), each bound to the private Gateway on its own private subdomain

## Integration

- **[`units/eks/addons/ebs_csi_driver`](../ebs_csi_driver/)**: `helm` depends on the `addon` and `storage_class/gp3` units being deployed first for persistent storage
- **[Gateway API](../gateway_api/)**: each `httproute/` unit attaches to [`gateway_api/gateway/private`](../gateway_api/gateway/private/), annotated `scope=private` so [ExternalDNS](../external_dns/) writes records to the private hosted zone
