variable "github_token" {
  description = "GitHub personal access token with 'repo' permissions. Required to create and manage GitHub Actions secrets"
  type        = string
  sensitive   = true
}

variable "github_repo_name" {
  description = "GitHub repository name where secrets will be stored"
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
}

variable "aws_role_arn" {
  description = "ARN of the IAM role that GitHub Actions will assume"
  type        = string
}