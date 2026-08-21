variable "private_subnets" {
  description = "Private subnet IDs, in AZ order"
  type        = list(string)
}

variable "private_subnets_cidr_blocks" {
  description = "Private subnet CIDR blocks, in the same AZ order as private_subnets"
  type        = list(string)
}

variable "endpoint_host_offsets" {
  description = "Host offset within each private subnet CIDR, per interface endpoint service"
  type        = map(number)
}

variable "app_param_key_map" {
  description = "Subset of endpoint_host_offsets keys, re-keyed to the appParams key each consumer expects"
  type        = map(string)
}
