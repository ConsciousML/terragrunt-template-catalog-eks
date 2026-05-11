# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the SecretStore resource"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy the SecretStore into"
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role ESO will assume to access AWS Secrets Manager"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the Secrets Manager secrets reside"
  type        = string
}
