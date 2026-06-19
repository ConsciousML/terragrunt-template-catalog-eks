# DNS Bootstrap: ArgoCD

Creates the public Route 53 hosted zone for the ArgoCD subdomain. See the [parent README](../README.md) for the DNS flow and pattern.

The ArgoCD subdomain is internal only. The EKS stack creates a matching private zone and ExternalDNS writes the A record pointing to the internal ALB. From the public internet, the public zone exists but has no A record.

## Deployment

### Prerequisites

Perform the [quickstart](../../../../README.md#getting-started) up to `Authenticate with AWS` (included).

### Configuration

Update `pipelines/dns.hcl` with your domain information:

```hcl
locals {
  base_domain      = "yourdomain.com"
  subdomain_argocd = "argocd"
}
```

### Deploy

Repeat the following for each environment (replacing `<environment>` with `dev` and then `ci`):

```bash
source .env
cd pipelines/bootstrap/setup_dns/argocd/<environment>/stack
terragrunt stack run init
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

Retrieve the 4 nameservers from the output:

```bash
terragrunt stack output --json setup_dns_argocd.route53_hosted_zone.name_servers
```

### Delegate the subdomain

In your domain registrar, add 4 NS records for the subdomain using the nameservers from the output above.

| Type | Host | Value |
|------|------|-------|
| NS | `argocd.<environment>` | `ns-123.awsdns-12.com` |
| NS | `argocd.<environment>` | `ns-456.awsdns-34.net` |
| NS | `argocd.<environment>` | `ns-789.awsdns-56.org` |
| NS | `argocd.<environment>` | `ns-012.awsdns-78.co.uk` |

### Verify propagation

```bash
dig NS argocd.<environment>.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`.
