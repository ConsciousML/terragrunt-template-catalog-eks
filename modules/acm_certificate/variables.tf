variable "domain_name" {
  description = "The domain name for the ACM certificate (e.g. argocd.dev.yourdomain.com)"
  type        = string
}

variable "zone_id" {
  description = "The Route53 hosted zone ID to create the DNS validation record in"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names to include as SANs on the ACM certificate"
  type        = list(string)
  default     = []
}
