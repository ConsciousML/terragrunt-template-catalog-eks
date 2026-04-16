resource "helm_release" "this" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  version          = var.helm_chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace

  values = [yamlencode(var.helm_values)]
}
