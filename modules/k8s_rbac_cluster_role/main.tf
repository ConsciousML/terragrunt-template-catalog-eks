resource "kubernetes_cluster_role" "this" {
  metadata {
    name          = var.name
    generate_name = var.generate_name
    labels        = var.labels
    annotations   = var.annotations
  }

  dynamic "aggregation_rule" {
    for_each = var.aggregation_rule != null ? [var.aggregation_rule] : []
    content {
      dynamic "cluster_role_selectors" {
        for_each = aggregation_rule.value.cluster_role_selectors
        content {
          match_labels = cluster_role_selectors.value.match_labels
          dynamic "match_expressions" {
            for_each = cluster_role_selectors.value.match_expressions
            content {
              key      = match_expressions.value.key
              operator = match_expressions.value.operator
              values   = match_expressions.value.values
            }
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = var.rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}
