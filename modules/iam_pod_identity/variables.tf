variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "iam_policy_name" {
  description = "Name of the IAM policy to create"
  type        = string
}

variable "iam_policy_json" {
  description = "IAM policy document as a JSON string"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM role to create"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the service account to associate with the role"
  type        = string
}

variable "service_account" {
  description = "Kubernetes service account name to associate with the role"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the IAM role"
  type        = map(string)
  default     = {}
}
