output "client_id" {
  description = "The WIF OAuth client ID"
  value       = tailscale_federated_identity.this.id
}

output "audience" {
  description = "The WIF audience value (api.tailscale.com/<client_id>)"
  value       = "api.tailscale.com/${tailscale_federated_identity.this.id}"
}
