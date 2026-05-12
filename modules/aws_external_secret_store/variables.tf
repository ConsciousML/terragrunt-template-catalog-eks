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

variable "aws_region" {
  description = "AWS region where the Secrets Manager secrets reside"
  type        = string
}
