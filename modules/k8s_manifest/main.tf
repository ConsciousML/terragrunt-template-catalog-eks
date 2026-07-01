resource "kubernetes_manifest" "this" {
  manifest = merge(
    {
      apiVersion = var.api_version
      kind       = var.kind
      metadata = merge(
        { name = var.name },
        var.namespace != null ? { namespace = var.namespace } : {},
        var.annotations != null ? { annotations = var.annotations } : {}
      )
    },
    var.fields
  )
}
