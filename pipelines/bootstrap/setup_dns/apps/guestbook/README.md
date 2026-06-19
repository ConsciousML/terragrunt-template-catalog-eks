# DNS Bootstrap: Guestbook

Creates the public Route 53 hosted zone for the Guestbook subdomain. See the [parent README](../../README.md) for the DNS flow and pattern.

The Guestbook subdomain is publicly reachable. There is no private zone counterpart. ExternalDNS writes the A record to this public zone, pointing to the internet facing ALB.

## Deployment

### Prerequisites

Perform the [quickstart](../../../../../README.md#getting-started) up to `Authenticate with AWS` (included).

### Configuration

Update `pipelines/dns.hcl` with your domain information:

```hcl
locals {
  base_domain         = "yourdomain.com"
  subdomain_guestbook = "guestbook"
}
```

### Deploy

Repeat the following for each environment (replacing `<environment>` with `dev` and then `ci`):

```bash
source .env
cd pipelines/bootstrap/setup_dns/apps/guestbook/<environment>/stack
terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive
```

Retrieve the 4 nameservers from the output:

```bash
terragrunt stack output --json setup_dns_guestbook.route53_hosted_zone.name_servers
```

### Delegate the subdomain

In your domain registrar, add 4 NS records for the subdomain using the nameservers from the output above.

| Type | Host | Value |
|------|------|-------|
| NS | `guestbook.<environment>` | `ns-123.awsdns-12.com` |
| NS | `guestbook.<environment>` | `ns-456.awsdns-34.net` |
| NS | `guestbook.<environment>` | `ns-789.awsdns-56.org` |
| NS | `guestbook.<environment>` | `ns-012.awsdns-78.co.uk` |

### Verify propagation

```bash
dig NS guestbook.<environment>.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`.
