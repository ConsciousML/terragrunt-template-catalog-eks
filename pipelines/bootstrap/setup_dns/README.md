# DNS Bootstrap

Creates a Route 53 hosted zone for the ArgoCD subdomain and outputs the nameservers to delegate to your domain registrar.

## Purpose

Run this **once per environment** before deploying the EKS stack. The hosted zone must exist and be authoritative for the subdomain before ACM can validate the TLS certificate.

The full DNS flow is:
1. This bootstrap creates the hosted zone and outputs 4 nameservers.
2. **Manual step**: Add those nameservers to your domain registrar as NS records for the subdomain, delegating authority to Route 53.
3. The EKS stack then handles everything else automatically: ACM issues the TLS certificate (validated via a CNAME in the hosted zone), and the Load Balancer Controller creates an ALB and adds an Alias A record pointing the subdomain to it.

## Multi Environment DNS Setup

Each environment needs its own Route 53 hosted zone so that ArgoCD can be deployed independently per env — `argocd.dev.yourdomain.com`, `argocd.staging.yourdomain.com`, `argocd.prod.yourdomain.com` — without zones or state clashing. Run this bootstrap once per environment, delegate the NS records, then deploy the [EKS stack](../../examples/stacks/eks/) which will pick up the zone automatically via a data source.

## Structure

One directory per environment, each deploying an independent hosted zone:

```
pipelines/bootstrap/setup_dns/
  dev/
    environment.hcl        ← environment = "dev"
    stack/
      terragrunt.stack.hcl
  staging/
    environment.hcl        ← environment = "staging"
    stack/
      terragrunt.stack.hcl
  prod/
    environment.hcl        ← environment = "prod"
    stack/
      terragrunt.stack.hcl
  example/
    environment.hcl        ← environment = "example"
    stack/
      terragrunt.stack.hcl
  ci/
    environment.hcl        ← environment = "catalog-eks-ci"
    stack/
      terragrunt.stack.hcl
```

The full domain is auto-constructed as `{subdomain}.{environment}.{base_domain}` (e.g. `argocd.dev.yourdomain.com`).

## Quick Start

### Prerequisites
- Follow the [installation instructions](../../README.md#installation)
- Same [prerequisites](../../README.md#prerequisites) as in the main `README.md`

### Configuration

In `pipelines/` change `region.hcl` to match your desired AWS region.

Update `pipelines/dns_config.hcl` with your domain:

```hcl
locals {
  base_domain = "yourdomain.com"
  subdomain   = "argocd"
}
```

You'll need to have a functional domain with access to the administrator panel. If you don't, please register a domain using a domain registrar such as GoDaddy or Namecheap.

### Deploy

Pick an environment and run from the root of this repository:

```bash
cd pipelines/bootstrap/setup_dns/<env>/stack
terragrunt stack generate
terragrunt stack run apply --backend-bootstrap --non-interactive
```

For example, to deploy the `dev` environment:

```bash
cd pipelines/bootstrap/setup_dns/dev/stack
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
| NS | `argocd.dev` | `ns-123.awsdns-12.com` |
| NS | `argocd.dev` | `ns-456.awsdns-34.net` |
| NS | `argocd.dev` | `ns-789.awsdns-56.org` |
| NS | `argocd.dev` | `ns-012.awsdns-78.co.uk` |

Replace `argocd.dev` with your actual `{subdomain}.{environment}` and each value with the nameservers from the output.

### Verify propagation

```bash
dig NS argocd.dev.yourdomain.com
```

Delegation is working when 4 AWS nameservers appear in the `ANSWER SECTION`. Propagation usually completes within minutes.

### Next Steps

With delegation in place, deploy the EKS stack normally. ACM certificate validation and the Route 53 Alias A record for the ALB are created automatically. No further manual DNS steps are required.
