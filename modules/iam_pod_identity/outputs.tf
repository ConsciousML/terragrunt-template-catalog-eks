output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "namespace" {
  description = "Kubernetes namespace of the associated service account"
  value       = aws_eks_pod_identity_association.this.namespace
}

output "service_account" {
  description = "Kubernetes service account name associated with the role"
  value       = aws_eks_pod_identity_association.this.service_account
}
