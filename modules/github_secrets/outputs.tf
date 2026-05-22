output "secrets_created" {
  description = "List of GitHub secrets that were created"
  value       = [for k, v in github_actions_secret.this : v.secret_name]
}
