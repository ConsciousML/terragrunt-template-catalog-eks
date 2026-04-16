variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "iam_policy_name" {
  description = "Name of the IAM policy to create for the AWS LBC"
  type        = string
}

variable "iam_policy_url" {
  description = "URL to the AWS LBC IAM policy JSON"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role to create for the AWS LBC"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the IAM role"
  type        = map(string)
  default     = {}
}
