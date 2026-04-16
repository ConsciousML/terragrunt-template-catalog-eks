output "role_arn" {
  description = "The ARN of the IAM role for the AWS LBC"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "The name of the IAM role for the AWS LBC"
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "The ARN of the IAM policy for the AWS LBC"
  value       = aws_iam_policy.this.arn
}
