resource "helm_release" "this" {
  name       = var.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.helm_chart_version
  namespace  = var.namespace
  # Uninstall can take longer than the provider's 300s default while ArgoCD cascades
  # deletes through its own Applications and their managed resources (issue #160).
  timeout = 600

  values = [yamlencode({
    applications = {
      (var.name) = {
        namespace  = var.namespace
        finalizers = var.finalizers
        project    = var.project
        source = merge(
          {
            repoURL        = var.repo_url
            targetRevision = var.target_revision
            path           = var.path
          },
          length(var.helm_values) > 0 ? {
            helm = { values = yamlencode(var.helm_values) }
          } : {}
        )
        destination = {
          server    = var.destination_server
          namespace = var.destination_namespace
        }
        syncPolicy = {
          syncOptions = var.sync_options
          automated   = { prune = var.prune }
        }
      }
    }
  })]
}
