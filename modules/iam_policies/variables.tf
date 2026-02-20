variable "role_name" {
  description = "Name of the IAM role to attach policies to"
  type        = string
}

variable "policy_arns" {
  description = "List of IAM policy ARNs to attach to the role (can be AWS managed policies or custom policy ARNs)"
  type        = list(string)

  validation {
    condition     = length(var.policy_arns) > 0
    error_message = "At least one policy ARN must be specified"
  }
}
