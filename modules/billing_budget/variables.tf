variable "thresholds_usd" {
  description = "USD amounts that each trigger their own notification when actual monthly spend exceeds them"
  type        = list(number)

  validation {
    condition     = length(var.thresholds_usd) > 0
    error_message = "At least one threshold must be provided."
  }

  validation {
    condition     = alltrue([for t in var.thresholds_usd : t > 0])
    error_message = "All thresholds must be greater than 0."
  }
}

variable "emails" {
  description = "Email addresses notified when actual spend crosses a configured threshold"
  type        = list(string)
  default     = []
}

variable "budget_name" {
  description = "Name of the AWS Budget"
  type        = string
  default     = "estimated-charges"
}
