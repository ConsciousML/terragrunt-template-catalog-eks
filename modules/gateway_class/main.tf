resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = var.name
    }
    spec = {
      controllerName = var.controller_name
    }
  }
}
