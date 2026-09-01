variable "service_code" {
  description = "AWS service code the quota belongs to, e.g. \"ec2\""
  type        = string
}

variable "quota_code" {
  description = "AWS Service Quota code to request an increase for, e.g. \"L-1216C47A\""
  type        = string
}

variable "desired_value" {
  description = "Requested value for the quota"
  type        = number

  validation {
    condition     = var.desired_value > 0
    error_message = "desired_value must be greater than 0."
  }
}
