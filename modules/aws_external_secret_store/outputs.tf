output "name" {
  description = "Name of the SecretStore resource"
  value       = var.name
}

output "namespace" {
  description = "Namespace the SecretStore was deployed into"
  value       = var.namespace
}
