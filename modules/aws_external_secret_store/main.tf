resource "kubernetes_manifest" "this" {
  manifest = {
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
          role    = var.iam_role_arn
          region  = var.aws_region
        }
      }
    }
  }
}
