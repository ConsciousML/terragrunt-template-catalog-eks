variable "issuer" {
  description = "OIDC issuer URL for the federated identity"
  type        = string
}

variable "subject" {
  description = "OIDC subject claim pattern (e.g. repo:<org>/<repo>:*)"
  type        = string
}

variable "scopes" {
  description = "OAuth scopes for auth keys issued via this federated identity"
  type        = set(string)
  default     = ["devices:core", "auth_keys", "dns"]
}

variable "tags" {
  description = "Tags assigned to devices authenticated via this federated identity"
  type        = set(string)
}
