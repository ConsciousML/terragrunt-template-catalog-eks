resource "kubectl_manifest" "this" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      refreshPolicy = var.refresh_policy
      secretStoreRef = {
        name = var.secret_store_name
        kind = var.secret_store_kind
      }
      target = {
        name           = var.target_secret_name
        creationPolicy = var.target_creation_policy
      }
      data = [
        for item in var.data : {
          secretKey = item.secret_key
          remoteRef = {
            key      = item.remote_key
            property = item.remote_property
          }
        }
      ]
    }
  })
}
