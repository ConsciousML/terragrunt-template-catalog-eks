# Route53

Provisions the DNS infrastructure and TLS certificate for the EKS cluster: a public hosted zone for external resolution and ACM validation, a private hosted zone for internal cluster services, and a wildcard ACM certificate for TLS termination.

## Concepts

- [Route53 public and private hosted zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html)
- [ACM DNS validation](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html)

## What's Inside

- **[hosted_zone_public](hosted_zone_public/)**: Manages the public hosted zone named `{environment}.{base_domain}` (e.g. `dev.axelmendoza.com`). Pre-created by the [`pipelines/bootstrap/setup_dns`](../../../pipelines/bootstrap/setup_dns/) pipeline, so `create = false` in the EKS stack. Its `zone_id` and `domain_name` outputs flow into `acm_certificate`
- **[hosted_zone_private](hosted_zone_private/)**: Creates a private hosted zone associated with the VPC for internal DNS resolution only
- **[acm_certificate](acm_certificate/)**: Issues a wildcard certificate for `*.{domain_env}`, `*.{domain_env_private}`, and `*.{domain_env_public}`, validated via DNS against the public hosted zone

## Integration

- **[`pipelines/bootstrap/setup_dns`](../../../pipelines/bootstrap/setup_dns/)**: creates the public hosted zone once and outputs NS records to delegate at the registrar. Must run before the EKS stack
- **[`units/eks/addons/gateway_api`](../addons/gateway_api/)**: the `load_balancer_configuration` unit references the ACM certificate ARN for the HTTPS listener
- **[`units/eks/addons/external_dns`](../addons/external_dns/)**: watches `HTTPRoute` and ingress resources and writes A records to the private hosted zone
- **[`units/eks/addons/tailscale/split_dns`](../addons/tailscale/split_dns/)**: takes an ordering dependency on the private hosted zone; the intercepted domain is read from `domains.hcl` rather than this zone's output
- **[`units/vpc`](../../vpc/)**: `hosted_zone_private` depends on the VPC ID to associate the private zone with the VPC
