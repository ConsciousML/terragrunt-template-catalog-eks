# DNS Bootstrap

Creates a Route 53 hosted zone for the ArgoCD subdomain and outputs the nameservers to delegate to your domain registrar.

## Purpose

Run this **once** before deploying the EKS stack. The hosted zone must exist and be authoritative for the subdomain before ACM can validate the TLS certificate.

The full DNS flow is:
1. This bootstrap creates the hosted zone and outputs 4 nameservers.
2. **Manual step**: Add those nameservers to your domain registrar as NS records for the subdomain, delegating authority to Route 53.
3. The EKS stack then handles everything else automatically: ACM issues the TLS certificate (validated via a CNAME in the hosted zone), and the Load Balancer Controller creates an ALB and adds an Alias A record pointing the subdomain to it.

## Quick Start

### Prerequisites
- Follow the [installation instructions](../../README.md#installation)
- Same [prerequisites](../../README.md#prerequisites) as in the main `README.md`

### Configuration

In `pipelines/` change `region.hcl` to match your desired AWS region.

Update the `domain_name` in `pipelines/dns_config.hcl`:

```hcl
locals {
  domain_name = "argocd.yourdomain.com"
}
```

You'll need to have a functional domain with access to the administrator panel. If you don't, please register a domain using a domain registrar such as GoDaddy or Namecheap.

### Deploy

From the root of this repository, run:
```bash
cd pipelines/bootstrap/setup_dns/
terragrunt stack generate
terragrunt stack run apply --backend-bootstrap --non-interactive
```

Retrieve the 4 nameservers from the output (the value of the `name_servers` key):
```bash
terragrunt stack output --json setup_dns.route53_hosted_zone.name_servers
```

### Delegate the subdomain

In your domain registrar, add 4 NS records for the subdomain using the nameservers from the output above.

| Type | Host | Value |
|------|------|-------|
| NS | `argocd` | `ns-123.awsdns-12.com` |
| NS | `argocd` | `ns-456.awsdns-34.net` |
| NS | `argocd` | `ns-789.awsdns-56.org` |
| NS | `argocd` | `ns-012.awsdns-78.co.uk` |

Replace `argocd` with your actual subdomain and each value with the nameservers from the output.

### Verify propagation

```bash
dig NS argocd.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`. Propagation usually completes within minutes.

### Next Steps

With delegation in place, deploy the EKS stack normally. ACM certificate validation and the Route 53 Alias A record for the ALB are created automatically. No further manual DNS steps are required.

