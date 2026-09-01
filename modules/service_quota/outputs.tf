output "id" {
  description = "The ID of the Service Quota request"
  value       = aws_servicequotas_service_quota.this.id
}

output "status" {
  description = "The status of the quota increase request (PENDING, CASE_OPENED, APPROVED, ...)"
  value       = aws_servicequotas_service_quota.this.request_status
}
