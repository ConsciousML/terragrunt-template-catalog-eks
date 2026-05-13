# DNS Bootstrap

Creates a public Route 53 hosted zone for the subdomain and outputs the nameservers to delegate to your domain registrar.

## Purpose

Run this **once per environment** before deploying the EKS stack. The public hosted zone must exist and be authoritative for the subdomain before ACM can validate the TLS certificate.

This bootstrap creates only the **public** zone. The EKS stack creates a matching **private** zone with the same domain name:

| Zone | Created by | Purpose |
|------|-----------|---------|
| Public | This bootstrap | Holds the ACM validation CNAME only. No A record. |
| Private | EKS stack | Holds the A record written by ExternalDNS, pointing to the internal ALB. |

From within the VPC, Route 53 private zones take precedence, so the domain resolves to the internal ALB. From the public internet, the public zone exists but has no A record.

The full DNS flow is:
1. This bootstrap creates the public hosted zone and outputs 4 nameservers.
2. **Manual step**: Add those nameservers to your domain registrar as NS records for the subdomain, delegating authority to Route 53.
3. The EKS stack handles everything else: ACM issues the TLS certificate (validated via a CNAME in the public zone), creates the private zone associated with the VPC, and ExternalDNS writes the A record to the private zone.

## Multi-Environment Setup

Each environment needs its own Route 53 hosted zone so that the subdomain can be deployed independently per env (`argocd.dev.yourdomain.com`, `argocd.staging.yourdomain.com`, `argocd.prod.yourdomain.com`, etc.) without zones or state clashing. Run this bootstrap once per environment, delegate the NS records, then deploy the [EKS stack](../../examples/stacks/eks/) which will pick up the public zone automatically via a data source and create the private zone.

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

Run this bootstrap for each environment you plan to deploy. Repeat the steps below for every directory listed above.

## Quick Start

### Prerequisites
- Follow the [installation instructions](../../README.md#installation)
- Same [prerequisites](../../README.md#prerequisites) as in the main `README.md`

### Configuration

In `pipelines/` change `region.hcl` to match your desired AWS region.

Update the `locals` block in each `terragrunt.stack.hcl` to match your repository:

```hcl
locals {
  github_username  = "YourGitHubUsername"
  github_repo_name = "your-repo-name"
}
```

Update `pipelines/dns.hcl` with your domain:

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
source .env
cd pipelines/bootstrap/setup_dns/<env>/stack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive
```

For example, to deploy the `dev` environment:

```bash
source .env
cd pipelines/bootstrap/setup_dns/dev/stack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive
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

With delegation in place, deploy the EKS stack normally. ACM certificate validation, private zone creation, and the ExternalDNS A record pointing to the internal ALB are all handled automatically. No further manual DNS steps are required.
