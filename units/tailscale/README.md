# Tailscale

Provisions the Tailscale authentication resources needed for GitHub Actions to authenticate to Tailscale during CI, without long-lived secrets.

## What's Inside

- **[workflow_identity_federation](workflow_identity_federation/)**: Creates a Tailscale Workload Identity Federation credential scoped to a GitHub repository via OIDC. CI authenticates using short-lived tokens instead of a stored OAuth secret. The credential is tagged `tag:ci`, which the [ACL](../eks/addons/tailscale/acl/) grants the right to create auth keys for `tag:k8s-operator`, the permission the Tailscale operator needs to register itself when deployed into the cluster. Its `client_id` and `audience` outputs flow into `github_secrets`
- **[github_secrets](github_secrets/)**: Stores `TS_OAUTH_CLIENT_ID`, `TS_AUDIENCE`, and `TS_TAGS` as GitHub secrets so CI workflows can authenticate to Tailscale at runtime

## Integration

- **[`pipelines/bootstrap/tailscale`](../../pipelines/bootstrap/tailscale/)**: orchestrates this group alongside the Tailscale ACL as a one-time bootstrap stack. Run it before deploying the Tailscale operator into any EKS cluster
- **[`units/eks/addons/tailscale`](../eks/addons/tailscale/)**: the per-cluster operator units consume the secrets provisioned here during CI deployments
