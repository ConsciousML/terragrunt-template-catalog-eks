# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the Connector resource"
  type        = string
}

variable "hostname_prefix" {
  description = "Hostname prefix for the connector device in the tailnet"
  type        = string
}

variable "advertise_routes" {
  description = "List of subnet CIDRs to advertise into the tailnet"
  type        = list(string)
}

variable "replicas" {
  description = "Number of connector replicas"
  type        = number
  default     = 1
}
