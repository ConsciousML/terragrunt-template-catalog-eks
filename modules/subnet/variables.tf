variable "vpc_id" {
  description = "The VPC ID where the subnet will be created"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "zone" {
  description = "The availability zone for the subnet"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the subnet"
  type        = map(string)
  default     = {}
}
