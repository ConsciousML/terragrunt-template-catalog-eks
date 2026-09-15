{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Tailscale ACL Bootstrap

The [`acl` unit](../../units/eks/addons/tailscale/acl/), deployed by the [`tailscale/acl` pipeline](../../pipelines/bootstrap/tailscale/acl/), applies the Tailscale [ACL policy](https://tailscale.com/kb/1018/acls) to the tailnet, auto-approving subnet routes for each environment's VPC CIDR so tagged nodes can advertise routes without manual approval in the Tailscale admin panel.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/tailscale).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `acl` | [`units/eks/addons/tailscale/acl`](../../units/eks/addons/tailscale/acl/) | [`modules/tailscale_acl`](../../modules/tailscale_acl/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `acl` | The tailnet policy file as a JSON string, built from `network.hcl`'s VPC CIDRs and the `ci_tag`. Use `jsonencode()` in the calling unit to construct it. | `string` | - | Yes |
| `overwrite_existing_content` | If true, skips the requirement to import the ACL resource before allowing changes. | `bool` | `false` | No |
| `reset_acl_on_destroy` | If true, resets the tailnet policy file to the Tailscale default when this resource is destroyed. | `bool` | `false` | No |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the Tailscale ACL resource. |
