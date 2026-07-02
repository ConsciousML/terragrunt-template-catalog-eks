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
- [External Secret Operator (ESO)](https://external-secrets.io/latest/)
- [ESO SecretStore](https://external-secrets.io/latest/api/secretstore/)
- [ESO ExternalSecret](https://external-secrets.io/latest/api/externalsecret/)

## What's Inside

Shared infrastructure for the whole stack:

- **[namespace](namespace/)**: Creates the `monitoring` namespace ahead of the Helm release, so the ESO units below can create namespaced resources before the chart ever installs
- **[aws_secret_store](aws_secret_store/)**: Creates an ESO `SecretStore` in the `monitoring` namespace backed by AWS Secrets Manager, shared by any tool in this stack that needs a secret synced in
- **[helm](helm/)**: Deploys the chart into the `monitoring` namespace (created by `namespace`), with `fullnameOverride` pinned so Service names are deterministic. Points Grafana at the ESO-owned `grafana-admin-credentials` secret via `helm_set`, and only deploys after `grafana/aws_external_secret` so the secret exists before Grafana's first boot — the chart never generates its own admin secret

Per-tool units, one directory per UI:

- **[grafana/](grafana/)**
  - **[aws_password_secret](grafana/aws_password_secret/)**: Generates a random Grafana admin password and stores it in AWS Secrets Manager. Its `secret_name` output flows into `aws_external_secret`
  - **[aws_external_secret](grafana/aws_external_secret/)**: Creates an ESO `ExternalSecret` that syncs the plaintext admin password from Secrets Manager into its own `grafana-admin-credentials` Kubernetes secret, owned by ESO rather than the Helm chart. Its `target_secret_name` and `secret_key` outputs flow into `helm`'s `grafana.admin.existingSecret`/`passwordKey` Helm values
  - **[httproute](grafana/httproute/)**: `HTTPRoute` for the Grafana UI, bound to the private Gateway on its own private subdomain
- **[prometheus/httproute](prometheus/httproute/)**: `HTTPRoute` for the Prometheus UI, bound to the private Gateway on its own private subdomain
- **[alertmanager/httproute](alertmanager/httproute/)**: `HTTPRoute` for the Alertmanager UI, bound to the private Gateway on its own private subdomain

## Integration

- **[`units/eks/addons/ebs_csi_driver`](../ebs_csi_driver/)**: `helm` depends on the `addon` and `storage_class/gp3` units being deployed first for persistent storage
- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: `aws_secret_store` and `grafana/aws_external_secret` depend on ESO being deployed and its IAM role being in place before creating the `SecretStore` and `ExternalSecret` resources
- **[Gateway API](../gateway_api/)**: each `httproute/` unit attaches to [`gateway_api/gateway/private`](../gateway_api/gateway/private/), annotated `scope=private` so [ExternalDNS](../external_dns/) writes records to the private hosted zone
