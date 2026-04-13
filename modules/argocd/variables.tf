variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

# https://artifacthub.io/packages/helm/argo/argo-cd
variable "helm_chart_version" {
  description = "The version of the helm chart of installing argocd"
  type        = string
}