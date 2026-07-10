# kube-prometheus-stack

Deploys [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster and workload metrics: Prometheus, Alertmanager, Grafana, kube-state-metrics, and node-exporter.

The Helm release, its HTTPRoutes, and its SecretStore/ExternalSecret are **not deployed by units in this repo**. They are deployed through app-of-apps as [`helm-kube-prometheus-stack`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-kube-prometheus-stack) (the chart), [`grafana-httproute`/`prometheus-httproute`/`alertmanager-httproute`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-httproute) (reusing the generic `helm-httproute` chart), and [`grafana-secrets`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) (reusing the generic `helm-eso-secret-sync` chart).

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

- **[grafana/aws_password_secret](grafana/aws_password_secret/)**: Generates a random Grafana admin password and stores it in AWS Secrets Manager. Its `secret_name` output flows into app-of-apps as a Helm value on `grafana-secrets`, which syncs the plaintext password into a `grafana-admin-credentials` Kubernetes secret that `helm-kube-prometheus-stack` points Grafana's `admin.existingSecret`/`passwordKey` at — the chart never generates its own admin secret

## Integration

- **[`units/eks/addons/ebs_csi_driver`](../ebs_csi_driver/)**: `helm-kube-prometheus-stack` needs the EBS CSI driver addon deployed first for its Prometheus/Alertmanager persistent storage; `units/eks/addons/argocd/app_of_apps` takes an ordering dependency on `ebs_csi_driver/addon` for this
- **[`units/eks/addons/argocd/app_of_apps`](../argocd/app_of_apps/)**: deploys the Helm release, HTTPRoutes, and SecretStore/ExternalSecret through app-of-apps. Takes an ordering dependency on `grafana/aws_password_secret` and passes its `secret_name` output through as a Helm value on `grafana-secrets`
