resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.5.0" # Specify the version for consistency
  namespace        = "argocd"
  create_namespace = true
}