# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "name" {
  description = "Name of the ClusterRoleBinding. Cannot be updated."
  type        = string
  default     = null
}

variable "generate_name" {
  description = "Prefix used by the server to generate a unique name when name is not provided."
  type        = string
  default     = null
}

variable "labels" {
  description = "Map of string keys and values used to organize and categorize the ClusterRoleBinding."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Unstructured key value map stored with the ClusterRoleBinding for arbitrary metadata."
  type        = map(string)
  default     = {}
}

variable "role_ref" {
  description = "References the ClusterRole to bind."
  type = object({
    api_group = string
    kind      = string
    name      = string
  })
}

variable "subjects" {
  description = "Entities to bind the ClusterRole to."
  type = list(object({
    kind      = string
    name      = string
    api_group = optional(string)
    namespace = optional(string)
  }))
}
