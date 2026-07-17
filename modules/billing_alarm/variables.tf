variable "thresholds_usd" {
  description = "USD amounts that each trigger their own CloudWatch alarm on estimated charges"
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
  description = "Email addresses to subscribe to the billing alarm SNS topic. Each address must confirm the subscription before receiving alerts."
  type        = list(string)
  default     = []
}

variable "alarm_name_prefix" {
  description = "Prefix used for the SNS topic name and each CloudWatch alarm name"
  type        = string
  default     = "estimated-charges"
}

variable "period" {
  description = "The period in seconds over which the EstimatedCharges statistic is applied"
  type        = number
  default     = 3600
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to each threshold"
  type        = number
  default     = 1
}

variable "datapoints_to_alarm" {
  description = "The number of data points that must be breaching to trigger each alarm"
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to assign to the SNS topic and CloudWatch alarms"
  type        = map(string)
  default     = {}
}
