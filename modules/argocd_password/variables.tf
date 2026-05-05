variable "secret_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
}

variable "length" {
  description = "Length of the generated password"
  type        = number
  default     = 16
}

variable "tags" {
  description = "Tags to apply to the Secrets Manager secret"
  type        = map(string)
  default     = {}
}
