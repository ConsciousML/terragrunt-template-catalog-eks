# DNS Bootstrap

Creates a public Route 53 hosted zone per subdomain and outputs the nameservers to delegate to your domain registrar.

## Usage

Deploy the ArgoCD subdomain: [argocd/README.md](argocd/README.md).
Deploy the Guestbook subdomain: [apps/guestbook/README.md](apps/guestbook/README.md).

## Purpose

Run this **once per subdomain per environment** before deploying the EKS stack. The public hosted zone must exist and be authoritative for the subdomain before ACM can validate the TLS certificate.

This bootstrap creates only the **public** zone. It holds the ACM validation CNAME only. No A record is written here.

From within the VPC, Route 53 private zones take precedence, so internal subdomains resolve to the internal ALB. From the public internet, the public zone exists but has no A record. Public subdomains (like Guestbook) have no private zone counterpart and resolve directly via the public zone.

The full DNS flow:
1. This bootstrap creates the public hosted zone and outputs 4 nameservers.
2. **Manual step**: Add those nameservers to your domain registrar as NS records for the subdomain, delegating authority to Route 53. Both delegations must be in place before deploying the EKS stack.
3. The EKS stack handles everything else: ACM issues the TLS certificate (validated via a CNAME in the public zone), and for internal subdomains ExternalDNS writes the A record to a private zone associated with the VPC.
