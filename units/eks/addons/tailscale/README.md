# Tailscale

Joins the EKS cluster to a Tailnet via the Tailscale Kubernetes operator, exposing private VPC subnets over VPN and enabling split DNS for internal cluster services. This gives developers VPN access to internal tools like ArgoCD without exposing them to the public internet.

## Concepts

- [Tailscale Kubernetes Operator](https://tailscale.com/kb/1236/kubernetes-operator)
- [Subnet routing](https://tailscale.com/kb/1019/subnets)
- [Split DNS](https://tailscale.com/kb/1054/dns)
- [ACL tags](https://tailscale.com/kb/1068/acl-tags)

## What's Inside

- **[acl](acl/)**: Applies the Tailscale ACL policy to the Tailnet. Defines the tags and auto-approves the VPC CIDR range for subnet routing. Part of the [`pipelines/bootstrap/tailscale`](../../../../pipelines/bootstrap/tailscale/) stack, not the EKS stack
- **[oauth_client_tailscale_operator](oauth_client_tailscale_operator/)**: Creates a Tailscale OAuth client for the operator. Its outputs flow into `operator`
- **[operator](operator/)**: Deploys the Tailscale Kubernetes operator via Helm, authenticated with the OAuth credentials from `oauth_client_tailscale_operator`. Registers the cluster into the Tailnet and implements the `Connector` CRD controller
- **[connector](connector/)**: Deploys a `Connector` resource that advertises the full VPC CIDR as a subnet route to the Tailnet, making all private cluster resources reachable over VPN. Depends on `operator` and `vpc`
- **[split_dns](split_dns/)**: Configures Tailscale split DNS to resolve the private Route53 hosted zone domain via the VPC DNS resolver, enabling short hostnames (e.g. `argocd.dev.axelmendoza.com`) to resolve over the Tailnet. Depends on `vpc` and `route53/hosted_zone_private`

## Integration

- **[`units/tailscale`](../../../tailscale/)**: provisions the WIF credential and GitHub secrets that allow CI to authenticate to Tailscale when deploying the operator
- **[`units/eks/route53/hosted_zone_private`](../../route53/hosted_zone_private/)**: `split_dns` reads its `domain_name` output to set the DNS domain Tailscale will intercept
- **[`units/vpc`](../../../vpc/)**: `connector` reads the VPC CIDR to advertise as a subnet route. `split_dns` derives the VPC DNS resolver address from it
