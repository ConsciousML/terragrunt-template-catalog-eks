# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the TargetGroupConfiguration resource"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy the TargetGroupConfiguration into"
  type        = string
}

variable "spec" {
  description = "Full spec of the TargetGroupConfiguration resource"
  type        = any
}
