variable "secret_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
}

variable "length" {
  description = "Length of the generated password"
  type        = number
  default     = 16
}

variable "recovery_window_in_days" {
  description = "Number of days that Secrets Manager waits before deleting the secret. Set to 0 for immediate deletion."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the Secrets Manager secret"
  type        = map(string)
  default     = {}
}
