variable "github_token" {
  description = "GitHub personal access token with 'repo' permissions"
  type        = string
  sensitive   = true
}

variable "github_repo_name" {
  description = "GitHub repository name where secrets will be stored"
  type        = string
}

variable "oauth_client_id" {
  description = "Tailscale WIF client ID (TS_OAUTH_CLIENT_ID)"
  type        = string
  sensitive   = true
}

variable "audience" {
  description = "Tailscale WIF audience value (TS_AUDIENCE)"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Comma-separated Tailscale tags assigned to CI runner devices (TS_TAGS)"
  type        = string
}
