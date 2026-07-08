variable "name" {
  description = "Name of the Secrets Manager secret"
  type        = string
}

variable "secret_data" {
  description = "Key/value pairs stored as a JSON-encoded Secrets Manager secret value"
  type        = map(string)
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days that Secrets Manager waits before deleting the secret. Set to 0 for immediate deletion."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags to apply to the Secrets Manager secret"
  type        = map(string)
  default     = {}
}
