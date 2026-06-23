resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = var.api_version
    kind       = var.kind
    metadata = merge(
      { name = var.name },
      var.namespace != null ? { namespace = var.namespace } : {}
    )
    spec = var.spec
  }
}
