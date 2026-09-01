resource "aws_servicequotas_service_quota" "this" {
  service_code = var.service_code
  quota_code   = var.quota_code
  value        = var.desired_value
}
