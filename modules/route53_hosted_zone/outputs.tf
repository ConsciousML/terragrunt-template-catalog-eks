output "zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "The list of name servers for the hosted zone (delegate these to your domain registrar)"
  value       = aws_route53_zone.this.name_servers
}
