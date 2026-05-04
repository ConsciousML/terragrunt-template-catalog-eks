# Bootstrap Pipelines

Run each of these pipelines **once** after forking this repository, before deploying any stack:

- **[Enable Terragrunt in GitHub Actions](enable_tg_github_actions/README.md)**: authenticates GitHub Actions with AWS via OIDC
- **[Setup DNS](setup_dns/README.md)**: creates a public Route53 hosted zone per environment for ACM certificate validation
- **[Tailscale](tailscale/README.md)**: sets up the ACL policy and OAuth client for the Tailscale Kubernetes operator

**Caution**: if you want to change the code of these pipelines, read the [For Developpers section](../../stacks/README.md#for-developpers).