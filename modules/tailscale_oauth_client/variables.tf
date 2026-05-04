variable "description" {
  description = "A description of the OAuth client"
  type        = string
}

variable "scopes" {
  description = "Scopes to grant to the client. See https://tailscale.com/kb/1623/ for available scopes."
  type        = set(string)
}

variable "tags" {
  description = "Tags that access tokens generated for the OAuth client will be able to assign to devices. Mandatory when scopes include 'devices:core' or 'auth_keys'."
  type        = set(string)
}
