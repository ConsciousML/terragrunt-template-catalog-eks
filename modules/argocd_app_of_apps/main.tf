resource "helm_release" "this" {
  name       = var.name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.helm_chart_version
  namespace  = var.namespace
  timeout    = 600

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
          retry = {
            limit = var.retry.limit
            backoff = {
              duration    = var.retry.backoff.duration
              factor      = var.retry.backoff.factor
              maxDuration = var.retry.backoff.max_duration
            }
          }
        }
      }
    }
  })]
}
