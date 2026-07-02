output "target_secret_name" {
  description = "Name of the Kubernetes Secret ESO writes into"
  value       = var.target_secret_name
}

output "namespace" {
  description = "Namespace the Kubernetes Secret lives in"
  value       = var.namespace
}

output "secret_key" {
  description = "Key written into the target Kubernetes Secret by the first data mapping"
  value       = var.data[0].secret_key
}
