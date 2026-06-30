variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "addon_name" {
  description = "Name of the EKS add-on"
  type        = string
}

variable "addon_version" {
  description = "Version of the EKS add-on. When null, the latest default version is used."
  type        = string
  default     = null
  nullable    = true
}

variable "resolve_conflicts_on_create" {
  description = "How to resolve field value conflicts when migrating a self-managed add-on. Valid values: NONE, OVERWRITE."
  type        = string
  default     = "OVERWRITE"
}

variable "resolve_conflicts_on_update" {
  description = "How to resolve field value conflicts when updating the add-on. Valid values: NONE, OVERWRITE, PRESERVE."
  type        = string
  default     = "OVERWRITE"
}

variable "configuration_values" {
  description = "Custom configuration values for the add-on as a JSON string."
  type        = string
  default     = null
  nullable    = true
}

variable "preserve" {
  description = "When true, created resources are preserved when the add-on is deleted."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the add-on."
  type        = map(string)
  default     = {}
}
