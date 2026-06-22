resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name       = var.name
      namespace  = var.namespace
      finalizers = var.finalizers
    }
    spec = {
      project = var.project
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
        automated = {
          prune = var.prune
        }
      }
    }
  }
}
