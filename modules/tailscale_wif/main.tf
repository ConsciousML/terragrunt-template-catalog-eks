resource "tailscale_federated_identity" "this" {
  issuer  = var.issuer
  subject = var.subject
  scopes  = var.scopes
  tags    = var.tags
}
