output "secrets_created" {
  description = "List of GitHub secrets that were created"
  value = [
    github_actions_secret.aws_region.secret_name,
    github_actions_secret.aws_role_arn.secret_name
  ]
}