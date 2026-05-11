output "namespace" {
  description = "Namespace the Helm release was deployed into"
  value       = helm_release.this.namespace
}
