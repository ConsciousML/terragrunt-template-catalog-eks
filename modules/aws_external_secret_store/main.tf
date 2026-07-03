resource "kubectl_manifest" "this" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region
        }
      }
    }
  })
}
