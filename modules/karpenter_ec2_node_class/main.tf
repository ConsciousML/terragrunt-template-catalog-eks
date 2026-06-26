resource "kubernetes_manifest" "this" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = var.name
    }
    spec = var.spec
  }
}
