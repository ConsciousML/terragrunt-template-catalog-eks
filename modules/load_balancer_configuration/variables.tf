# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the LoadBalancerConfiguration resource"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy the LoadBalancerConfiguration into"
  type        = string
}

variable "spec" {
  description = "Full spec of the LoadBalancerConfiguration resource"
  type        = any
}
