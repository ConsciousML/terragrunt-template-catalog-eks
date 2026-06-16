output "name" {
  description = "Name of the created ClusterRoleBinding"
  value       = kubernetes_cluster_role_binding.this.metadata[0].name
}
