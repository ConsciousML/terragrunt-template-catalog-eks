# DNS Bootstrap

Creates one public Route 53 hosted zone per environment (`<environment>.yourdomain.com`) and outputs the nameservers to delegate to your domain registrar. Delegate once and all apps in that environment share the zone.

## Purpose

Run this **once per environment** before deploying the EKS stack. The public hosted zone must exist and be authoritative before ACM can validate TLS certificates for any app in the environment.

This bootstrap creates only the **public** zone. The [EKS stack](../../dev/eks/stack/) creates a matching private zone and wires ACM, ExternalDNS, and TLS on top. See the [route53](../../../units/eks/route53/README.md) and [external_dns](../../../units/eks/addons/external_dns/README.md) unit docs for details.

The full DNS flow:
1. This bootstrap creates the [public hosted zone](../../../units/eks/route53/hosted_zone_public/terragrunt.hcl) and outputs 4 nameservers.
2. **Manual step**: Add those nameservers to your domain registrar as NS records for `<environment>.yourdomain.com`, delegating authority to Route 53.
3. The EKS stack handles the rest. New apps only need an ACM cert unit, no new zone and no new registrar touch.

## Deployment

### Prerequisites

Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

### Configuration

Update `pipelines/dns.hcl` with your domain:

```hcl
locals {
  base_domain            = "yourdomain.com"
  subdomain_argocd       = "argocd"
  subdomain_guestbook    = "guestbook"
  subdomain_prometheus   = "prometheus"
  subdomain_alertmanager = "alertmanager"
  subdomain_grafana      = "grafana"
}
```

### Deploy

Repeat the following for each environment (replacing `<environment>` with `dev` and then `ci`), from the root directory of this repository:

```bash
source .env
cd pipelines/bootstrap/setup_dns/<environment>
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Retrieve the 4 nameservers from the output:

```bash
terragrunt stack output --json setup_dns.route53_hosted_zone.name_servers
```

### Delegate the zone

In your domain registrar, add 4 NS records for the environment subdomain using the nameservers from the output above.

| Type | Host | Value |
|------|------|-------|
| NS | `<environment>` | `ns-123.awsdns-12.com` |
| NS | `<environment>` | `ns-456.awsdns-34.net` |
| NS | `<environment>` | `ns-789.awsdns-56.org` |
| NS | `<environment>` | `ns-012.awsdns-78.co.uk` |

### Verify propagation

```bash
dig NS <environment>.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`.
