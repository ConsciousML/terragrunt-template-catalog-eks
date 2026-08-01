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

- **[crds](crds/)**: Installs the Prometheus Operator CRDs (`ServiceMonitor`, `PrometheusRule`, ...) via Terraform, ahead of ArgoCD. `units/eks/addons/argocd/helm` depends on it so the CRDs exist before ArgoCD's own Helm release or any app-of-apps `Application` renders a `ServiceMonitor`. `helm-kube-prometheus-stack` sets `crds.enabled: false` so this unit stays the CRDs' only owner
- **[grafana/aws_secret_password](grafana/aws_secret_password/)**: Generates a random Grafana admin password and stores it in AWS Secrets Manager. The chart never generates its own admin secret, Grafana's admin credentials always come from this secret via ESO. `app_of_apps` depends on it so the password exists before ESO tries to sync it
- **[alertmanager/aws_secret_slack_bot](alertmanager/aws_secret_slack_bot/)**: Stores the Slack bot token (see [environment variables](../../../../docs/environment-variables.md) for `SLACK_BOT_TOKEN`) in AWS Secrets Manager, used by Alertmanager to post to Slack
- **[`helm-kube-prometheus-stack`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-kube-prometheus-stack)** (app-of-apps): the chart itself. Not deployed by this unit
- **`grafana-httproute`, `prometheus-httproute`, `alertmanager-httproute`** (app-of-apps): instances of the generic [`helm-httproute`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-httproute) chart, exposing the stack's UIs
- **`grafana-secrets`** (app-of-apps): an instance of the generic [`helm-eso-secret-sync`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) chart, syncs `grafana/aws_secret_password` into the cluster
- **`alertmanager-secrets`** (app-of-apps): an instance of the generic [`helm-eso-secret-sync`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) chart, syncs `alertmanager/aws_secret_slack_bot` into the cluster so Alertmanager can send alerts to Slack

## Upstream Dependencies

- **[`units/eks/addons/ebs_csi_driver`](../ebs_csi_driver/)**: `units/eks/addons/argocd/app_of_apps` depends on `ebs_csi_driver/addon` so the driver exists before ArgoCD deploys anything backed by persistent storage
