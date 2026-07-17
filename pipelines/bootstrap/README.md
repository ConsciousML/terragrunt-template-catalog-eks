# Bootstrap Pipelines

Run each of these pipelines **once** after forking this repository, before deploying any stack:

- **[AWS GitHub Actions Auth](aws_gh_actions_auth/README.md)**: authenticates GitHub Actions with AWS via OIDC
- **[Billing Budgets](billing_budgets/README.md)**: creates an AWS Budget that emails a notification when estimated charges cross a configured threshold
- **[Setup DNS](setup_dns/README.md)**: creates a public Route53 hosted zone per environment for ACM certificate validation
- **[Tailscale](tailscale/README.md)**: sets up the ACL policy and OAuth client for the Tailscale Kubernetes operator

**Caution**: if you want to change the code of these pipelines, read the [For Developpers section](../../stacks/README.md#for-developpers).