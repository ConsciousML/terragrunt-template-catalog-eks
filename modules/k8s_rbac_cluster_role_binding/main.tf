resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name          = var.name
    generate_name = var.generate_name
    labels        = var.labels
    annotations   = var.annotations
  }

  role_ref {
    api_group = var.role_ref.api_group
    kind      = var.role_ref.kind
    name      = var.role_ref.name
  }

  dynamic "subject" {
    for_each = var.subjects
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      api_group = subject.value.api_group
      namespace = subject.value.namespace
    }
  }
}
