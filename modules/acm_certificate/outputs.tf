output "certificate_arn" {
  description = "The certificate ARN created by ACM"
  value       = aws_acm_certificate_validation.this.certificate_arn
}