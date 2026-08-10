# Tailscale

Joins the EKS cluster to a Tailnet via the Tailscale Kubernetes operator, exposing private VPC subnets over VPN and enabling split DNS for internal cluster services. This gives developers VPN access to internal tools like ArgoCD without exposing them to the public internet.

## Concepts

- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)
- [Subnet routing](https://tailscale.com/kb/1019/subnets)
- [Split DNS](https://tailscale.com/kb/1054/dns)
- [ACL tags](https://tailscale.com/kb/1068/acl-tags)
- [External Secret Operator (ESO)](https://external-secrets.io/latest/)

## What's Inside

- **[acl](acl/)**: Applies the Tailscale ACL policy to the Tailnet, auto-approving subnet routes for the VPC CIDR so tagged nodes can advertise routes without manual approval in the Tailscale admin panel. Part of the [`pipelines/bootstrap/tailscale`](../../../../pipelines/bootstrap/tailscale/) stack, not the EKS stack
- **[oauth_client_tailscale_operator](oauth_client_tailscale_operator/)**: Creates a Tailscale OAuth client for the operator
- **[oauth_client_secret](oauth_client_secret/)**: Stores `oauth_client_tailscale_operator`'s credentials in AWS Secrets Manager
- **[split_dns/default](split_dns/default/)**: Configures Tailscale split DNS to route queries for `domain_env_private` (e.g. `private.dev.axelmendoza.com`) through the VPC DNS resolver, so private hostnames resolve over the Tailnet without intercepting public endpoints. Reads `domain_env_private` from `domains.hcl`
- **[split_dns/eks](split_dns/eks/)**: Configures Tailscale split DNS to route queries for the region's EKS private endpoint domain (`<region>.eks.amazonaws.com`) through the VPC DNS resolver, so the private EKS API endpoint resolves over the Tailnet
- **[`tailscale-operator`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/tailscale/operator)** (app-of-apps): deploys the operator Helm release itself. Not deployed by this unit
- **[`tailscale-connector`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/tailscale/connector)** (app-of-apps): deploys the `Connector` CR. Not deployed by this unit
- **[`tailscale-secrets`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/external-secrets-operator/secret-sync)** (app-of-apps): an instance of the generic `secret-sync` chart, syncs the OAuth credentials into the operator's expected `operator-oauth` secret via an ESO `SecretStore` and `ExternalSecret`, mirroring how ArgoCD's admin password is synced

See the [App of Apps integration guide](../../../../docs/app-of-apps-integration.md) to understand how these apps are wired to Terraform-sourced values.

## Upstream Dependencies

- **[`units/tailscale`](../../../tailscale/)**: provisions the WIF credential and GitHub secrets that allow CI to authenticate to Tailscale when deploying the operator
- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: its IAM role must be in place before the ESO controller (deployed through app-of-apps) can read the OAuth secret
- **[`units/eks/route53/hosted_zone_private`](../../route53/hosted_zone_private/)**: `split_dns/default` depends on it to ensure the private zone exists before configuring Tailscale DNS. The intercepted domain is read from `domains.hcl` (`domain_env_private`), not from this unit's output
- **[`units/vpc`](../../../vpc/)**: `split_dns/default` and `split_dns/eks` both derive the VPC DNS resolver address from it
