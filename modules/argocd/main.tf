resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.helm_chart_version
  namespace        = "argocd"
  create_namespace = true

  values = [yamlencode(var.helm_values)]
}