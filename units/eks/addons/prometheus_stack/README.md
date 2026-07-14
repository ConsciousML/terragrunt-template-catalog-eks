# kube-prometheus-stack

Deploys [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster and workload metrics: Prometheus, Alertmanager, Grafana, kube-state-metrics, and node-exporter.

The following components of the stack are deployed in the app-of-apps repository, not by units in this repo:

- [`helm-kube-prometheus-stack`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-kube-prometheus-stack): the chart itself
- `grafana-httproute`, `prometheus-httproute`, and `alertmanager-httproute`: instances of the generic [`helm-httproute`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-httproute) chart
- `grafana-secrets`: an instance of the generic [`helm-eso-secret-sync`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) chart

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

- **[grafana/aws_secret_password](grafana/aws_secret_password/)**: Generates a random Grafana admin password and stores it in AWS Secrets Manager. The chart never generates its own admin secret, Grafana's admin credentials always come from this secret via ESO

## Integration

- **[`units/eks/addons/ebs_csi_driver`](../ebs_csi_driver/)**: `units/eks/addons/argocd/app_of_apps` takes an ordering dependency on `ebs_csi_driver/addon` so the driver exists before ArgoCD deploys anything backed by persistent storage
- **[`units/eks/addons/argocd/app_of_apps`](../argocd/app_of_apps/)**: deploys the Helm release, HTTPRoutes, and SecretStore and ExternalSecret through app-of-apps. Takes an ordering dependency on `grafana/aws_secret_password` so the password exists before ESO tries to sync it
