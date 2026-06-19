resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = var.spec
  }
}
