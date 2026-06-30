output "arn" {
  description = "Amazon Resource Name (ARN) of the EKS add-on"
  value       = aws_eks_addon.this.arn
}
