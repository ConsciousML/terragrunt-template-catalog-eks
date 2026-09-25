{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

# Security Improvements

Optional hardening steps you can apply on top of a [deployed](/docs/quickstart/deployment/) environment.

## Disable the Public EKS Endpoint

For improved security, set `endpoint_public_access` to `false` in the `cluster` unit's `values` block of your [environment](/docs/iac/#environments)'s `eks/stack/terragrunt.stack.hcl` file:

```hcl
unit "cluster" {
  ...
  values = {
    ...
    endpoint_public_access = false
  }
}
```

Then re-apply the stack:
- `dev`: see [Run the Terragrunt Stack](/docs/quickstart/deployment/#run-the-terragrunt-stack).
- `staging` and `prod`: see [How to Edit the Live Configuration](/docs/iac/edit-live-configuration/).

From this point on, `kubectl` and the AWS CLI can only reach the API server while connected to Tailscale.

:::warning
Set `endpoint_public_access` back to `true` and re-apply the `cluster` unit before [destroying the stack](/docs/quickstart/deployment/#destroy-the-infrastructure). Destroying it removes the [Tailscale components](/docs/security/tailscale/), your only path back into the cluster API while the endpoint is private.
:::
