resource "tailscale_oauth_client" "this" {
  description = var.description
  scopes      = var.scopes
  tags        = var.tags
}
