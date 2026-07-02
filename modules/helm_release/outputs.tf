output "namespace" {
  description = "Namespace the Helm release was deployed into"
  value       = helm_release.this.namespace
}

output "name" {
  description = "Name of the Helm release"
  value       = helm_release.this.name
}
