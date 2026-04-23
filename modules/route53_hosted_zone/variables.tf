variable "name" {
  description = "The name of the hosted zone (e.g. example.com)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*$", var.name))
    error_message = "Name must be a valid domain name."
  }
}

variable "comment" {
  description = "A comment for the hosted zone"
  type        = string
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "A map of tags to assign to the hosted zone"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "If true, create the hosted zone. If false, look it up via data source (zone must already exist)."
  type        = bool
  default     = true
}

variable "private_zone" {
  description = "If true, the hosted zone is private. Used for data source lookup when create = false."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID to associate with the hosted zone. When set, the created zone is private. Only used when create = true."
  type        = string
  default     = null
}
