{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Setup DNS Bootstrap

The [`setup_dns` stack](../../stacks/setup_dns/) provisions a public [Route 53](https://aws.amazon.com/route53/) [hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) for an environment, the container for the DNS records that route traffic to its domain and that [ACM](https://aws.amazon.com/certificate-manager/) uses to validate its TLS certificate.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/setup_dns).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `route53_hosted_zone` | [`units/eks/route53/hosted_zone_public`](../../units/eks/route53/hosted_zone_public/) | [`modules/route53_hosted_zone`](../../modules/route53_hosted_zone/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `base_domain` | Base domain configured in [`pipelines/dns.hcl`](../../pipelines/dns.hcl). Combined with the environment name to form the hosted zone's domain name (`<environment>.<base_domain>`). | `string` | - | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `zone_id` | The hosted zone ID. |
| `name_servers` | The list of name servers for the hosted zone. Delegate these to your domain registrar. |
| `domain_name` | The full domain name of the hosted zone. |
