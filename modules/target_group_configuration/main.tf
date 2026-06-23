resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "gateway.k8s.aws/v1beta1"
    kind       = "TargetGroupConfiguration"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = var.spec
  }
}
