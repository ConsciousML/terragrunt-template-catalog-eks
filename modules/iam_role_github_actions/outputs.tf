output "role_arn" {
  description = "The ARN of the IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.github_actions.name
}
