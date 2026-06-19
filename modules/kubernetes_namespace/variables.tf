# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the namespace"
  type        = string
}
