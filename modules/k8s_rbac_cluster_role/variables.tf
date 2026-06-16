# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "name" {
  description = "Name of the ClusterRole. Cannot be updated."
  type        = string
  default     = null
}

variable "generate_name" {
  description = "Prefix used by the server to generate a unique name when name is not provided."
  type        = string
  default     = null
}

variable "labels" {
  description = "Map of string keys and values used to organize and categorize the ClusterRole."
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Unstructured key value map stored with the ClusterRole for arbitrary metadata."
  type        = map(string)
  default     = {}
}

variable "aggregation_rule" {
  description = "Describes how to build the Rules for this ClusterRole via label selector aggregation."
  type = object({
    cluster_role_selectors = list(object({
      match_labels = optional(map(string), {})
      match_expressions = optional(list(object({
        key      = string
        operator = string
        values   = set(string)
      })), [])
    }))
  })
  default = null
}

variable "rules" {
  description = "List of PolicyRules for this ClusterRole."
  type = list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
  default = []
}
