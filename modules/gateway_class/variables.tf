# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the GatewayClass"
  type        = string
}

variable "controller_name" {
  description = "Name of the controller that manages this GatewayClass (e.g. gateway.k8s.aws/alb)"
  type        = string
}
