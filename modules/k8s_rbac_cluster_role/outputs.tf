output "name" {
  description = "Name of the created ClusterRole"
  value       = kubernetes_cluster_role.this.metadata[0].name
}
