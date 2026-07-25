# Base channel names (no environment prefix, no leading '#'), shared by every environment's
# channels/<environment>/stack. Must stay in sync with the suffix (after "{{ .Values.environment }}-")
# of each `kube-prometheus-stack.alertmanager.config.receivers[].slack_configs[].channel` entry in
# https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-kube-prometheus-stack/values.yaml
locals {
  channel_names = [
    "k8s-critical",
    "k8s-warning",
    "prometheus-stack-critical",
    "prometheus-stack-warning",
    "watchdog",
    "unrouted",
  ]
}
