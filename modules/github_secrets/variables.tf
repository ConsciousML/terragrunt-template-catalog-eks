variable "github_token" {
  description = "GitHub personal access token with 'repo' permissions. Required to create and manage GitHub Actions secrets"
  type        = string
  sensitive   = true
}

variable "github_repo_name" {
  description = "GitHub repository name where secrets will be stored"
  type        = string
}

variable "secrets" {
  description = "Map of GitHub Actions secret names to their plaintext values"
  type        = map(string)
}
