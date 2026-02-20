variable "url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type        = string

  validation {
    condition     = can(regex("^https://", var.url))
    error_message = "URL must start with https://"
  }
}

variable "client_id_list" {
  description = "List of client IDs (audiences) that can request tokens from the OIDC provider"
  type        = list(string)

  validation {
    condition     = length(var.client_id_list) > 0
    error_message = "At least one client ID must be specified"
  }
}

variable "thumbprint_list" {
  description = "List of server certificate thumbprints. Optional for GitHub Actions as it's in AWS's trusted CA library"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the OIDC provider"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Whether to create or retrieve an existing OIDC provider using a data source"
  type        = bool
}
