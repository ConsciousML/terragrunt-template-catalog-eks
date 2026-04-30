resource "kubernetes_manifest" "connector" {
  manifest = {
    apiVersion = "tailscale.com/v1alpha1"
    kind       = "Connector"
    metadata = {
      name = var.name
    }
    spec = {
      hostnamePrefix = var.hostname_prefix
      replicas       = var.replicas
      subnetRouter = {
        advertiseRoutes = var.advertise_routes
      }
    }
  }
}
