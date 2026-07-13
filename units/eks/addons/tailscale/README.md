# Tailscale

Joins the EKS cluster to a Tailnet via the Tailscale Kubernetes operator, exposing private VPC subnets over VPN and enabling split DNS for internal cluster services. This gives developers VPN access to internal tools like ArgoCD without exposing them to the public internet.

## Concepts

- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)
- [Subnet routing](https://tailscale.com/kb/1019/subnets)
- [Split DNS](https://tailscale.com/kb/1054/dns)
- [ACL tags](https://tailscale.com/kb/1068/acl-tags)
- [External Secret Operator (ESO)](https://external-secrets.io/latest/)

## What's Inside

- **[acl](acl/)**: Applies the Tailscale ACL policy to the Tailnet. Defines three tags: `tag:ci` (assigned to GitHub Actions runners that join via WIF), `tag:k8s-operator` (owned by `tag:ci`, assigned to the Tailscale Kubernetes operator), and `tag:k8s` (owned by `tag:k8s-operator`, assigned to nodes managed by the operator). Auto-approves subnet routes for the VPC CIDR so tagged nodes can advertise routes without manual approval in the Tailscale admin panel. Part of the [`pipelines/bootstrap/tailscale`](../../../../pipelines/bootstrap/tailscale/) stack, not the EKS stack
- **[oauth_client_tailscale_operator](oauth_client_tailscale_operator/)**: Creates a Tailscale OAuth client for the operator
- **[oauth_client_secret](oauth_client_secret/)**: Stores `oauth_client_tailscale_operator`'s `client_id`/`client_secret` in AWS Secrets Manager. Its `secret_name` output flows into `app_of_apps`
- **[split_dns](split_dns/)**: Configures Tailscale split DNS to route queries for `domain_env_private` (e.g. `private.dev.axelmendoza.com`) through the VPC DNS resolver, so private hostnames resolve over the Tailnet without intercepting public endpoints. Reads `domain_env_private` from `domains.hcl`. Depends on `vpc` and `route53/hosted_zone_private`

The operator Helm release and the `Connector` CR are deployed through app-of-apps (`helm-tailscale-operator` and `helm-tailscale-connector`), not Terraform. The ESO `SecretStore`/`ExternalSecret` that sync the OAuth credentials into the operator's expected `operator-oauth` secret are also deployed through app-of-apps (`tailscale-secrets`, an instance of the generic [`helm-eso-secret-sync`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) chart), mirroring how ArgoCD's admin password is synced. See the [App of Apps integration guide](../../../../docs/app-of-apps-integration.md).

## Integration

- **[`units/tailscale`](../../../tailscale/)**: provisions the WIF credential and GitHub secrets that allow CI to authenticate to Tailscale when deploying the operator
- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: its IAM role must be in place before the ESO controller (deployed through app-of-apps) can read the OAuth secret
- **[`units/eks/addons/argocd/app_of_apps`](../argocd/app_of_apps/)**: reads `oauth_client_secret`'s `secret_name` and the VPC CIDR to inject them into `helm-tailscale-connector`'s and `tailscale-secrets`' Helm values
- **[`units/eks/route53/hosted_zone_private`](../../route53/hosted_zone_private/)**: `split_dns` takes an ordering dependency to ensure the private zone exists before configuring Tailscale DNS; the intercepted domain is read from `domains.hcl` (`domain_env_private`), not from this unit's output
- **[`units/vpc`](../../../vpc/)**: `split_dns` derives the VPC DNS resolver address from it; `app_of_apps` reads the VPC CIDR to advertise as a subnet route in `helm-tailscale-connector`
