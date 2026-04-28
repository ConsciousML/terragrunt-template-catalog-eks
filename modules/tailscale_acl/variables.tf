variable "acl" {
  description = "The tailnet policy file as a JSON string. Use jsonencode() in the calling unit to construct the policy."
  type        = string
}

variable "overwrite_existing_content" {
  description = "If true, skips the requirement to import the ACL resource before allowing changes"
  type        = bool
  default     = false
}

variable "reset_acl_on_destroy" {
  description = "If true, resets the tailnet policy file to the Tailscale default when this resource is destroyed"
  type        = bool
  default     = false
}
