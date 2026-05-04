resource "tailscale_acl" "this" {
  acl                        = var.acl
  overwrite_existing_content = var.overwrite_existing_content
  reset_acl_on_destroy       = var.reset_acl_on_destroy
}
