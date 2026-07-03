output "name" {
  description = "Name of the Kubernetes resource"
  value       = var.name
}

output "namespace" {
  description = "Namespace the resource was deployed into; null for cluster-scoped resources"
  value       = var.namespace
}
