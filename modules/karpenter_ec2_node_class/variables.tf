# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "EKS cluster name, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the EC2NodeClass"
  type        = string
}

variable "spec" {
  description = "Full spec of the EC2NodeClass"
  type        = any
}
