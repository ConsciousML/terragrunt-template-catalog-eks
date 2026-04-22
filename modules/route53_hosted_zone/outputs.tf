locals {
  zone = var.create ? aws_route53_zone.this[0] : data.aws_route53_zone.this[0]
}

output "zone_id" {
  description = "The hosted zone ID"
  value       = local.zone.zone_id
}

output "name_servers" {
  description = "The list of name servers for the hosted zone (delegate these to your domain registrar)"
  value       = local.zone.name_servers
}

output "domain_name" {
  description = "The full domain name of the hosted zone"
  value       = local.zone.name
}
