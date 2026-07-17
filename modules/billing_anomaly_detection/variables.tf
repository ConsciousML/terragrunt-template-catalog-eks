variable "monitor_name" {
  description = "Name of the Cost Anomaly Detection monitor"
  type        = string
  default     = "anomaly-monitor"
}

variable "monitor_dimension" {
  description = "The dimension the monitor evaluates for anomalies"
  type        = string
  default     = "SERVICE"

  validation {
    condition     = contains(["COST_CATEGORY", "LINKED_ACCOUNT", "SERVICE", "TAG"], var.monitor_dimension)
    error_message = "monitor_dimension must be one of \"COST_CATEGORY\", \"LINKED_ACCOUNT\", \"SERVICE\", \"TAG\"."
  }
}

variable "subscription_name" {
  description = "Name of the Cost Anomaly Detection alert subscription"
  type        = string
  default     = "anomaly-subscription"
}

variable "threshold_usd" {
  description = "The dollar impact an anomaly must reach or exceed before triggering a notification"
  type        = number

  validation {
    condition     = var.threshold_usd >= 0
    error_message = "threshold_usd must be greater than or equal to 0."
  }
}

variable "frequency" {
  description = "How often anomaly alerts are sent. Valid values: DAILY, IMMEDIATE, WEEKLY"
  type        = string
  default     = "DAILY"

  validation {
    condition     = contains(["DAILY", "IMMEDIATE", "WEEKLY"], var.frequency)
    error_message = "frequency must be one of \"DAILY\", \"IMMEDIATE\", \"WEEKLY\"."
  }
}

variable "emails" {
  description = "Email addresses notified when an anomaly reaches or exceeds threshold_usd"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the monitor and subscription"
  type        = map(string)
  default     = {}
}
