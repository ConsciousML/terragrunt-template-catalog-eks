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

variable "inline_policies" {
  description = "List of inline policies to attach to the IAM role"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}
