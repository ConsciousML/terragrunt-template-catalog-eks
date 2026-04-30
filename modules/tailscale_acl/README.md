<!-- BEGIN_TF_DOCS -->
# tailscale\_acl

Manages the tailnet-wide ACL policy file, defining tag ownership and auto-approval rules for subnet routes advertised by the Kubernetes operator.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | ~> 0.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | ~> 0.28.0 |

## Resources

| Name | Type |
|------|------|
| [tailscale_acl.this](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs/resources/acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acl"></a> [acl](#input\_acl) | The tailnet policy file as a JSON string. Use jsonencode() in the calling unit to construct the policy. | `string` | n/a | yes |
| <a name="input_overwrite_existing_content"></a> [overwrite\_existing\_content](#input\_overwrite\_existing\_content) | If true, skips the requirement to import the ACL resource before allowing changes | `bool` | `false` | no |
| <a name="input_reset_acl_on_destroy"></a> [reset\_acl\_on\_destroy](#input\_reset\_acl\_on\_destroy) | If true, resets the tailnet policy file to the Tailscale default when this resource is destroyed | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Tailscale ACL resource |
<!-- END_TF_DOCS -->