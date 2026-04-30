variable "domain" {
  description = "The domain suffix whose DNS queries will be forwarded to the nameservers"
  type        = string
}

variable "nameservers" {
  description = "List of nameserver IPs to forward DNS queries to"
  type        = list(string)
}
