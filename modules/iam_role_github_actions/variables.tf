variable "name" {
  description = "Name of the IAM role"
  type        = string
}

variable "github_username" {
  description = "GitHub username or organization name"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch name or pattern (use '*' for all branches)"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the IAM role"
  type        = map(string)
  default     = {}
}
