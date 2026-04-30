resource "tailscale_dns_split_nameservers" "this" {
  domain      = var.domain
  nameservers = var.nameservers
}
