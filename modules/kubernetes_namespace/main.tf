resource "kubectl_manifest" "this" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.name
    }
  })
}
