# Bootstrap Pipelines

Run each of these pipelines **once** after forking this repository, before deploying any stack:

- **[AWS Billing Alerts](aws_billing_alerts/README.md)**: creates AWS Budgets and a Cost Anomaly Detection monitor that email a notification when spend crosses a configured threshold
- **[AWS GitHub Actions Auth](aws_gh_actions_auth/README.md)**: authenticates GitHub Actions with AWS via OIDC
- **[Setup DNS](setup_dns/README.md)**: creates a public Route53 hosted zone per environment for ACM certificate validation
- **[Slack](slack/README.md)**: registers the Slack bot token as a GitHub Actions secret so CI-deployed Alertmanager instances can send notifications to Slack
- **[Tailscale](tailscale/README.md)**: sets up the ACL policy and OAuth client for the Tailscale Kubernetes operator

**Caution**: if you want to change the code of these pipelines, read the [For Developpers section](../../stacks/README.md#for-developpers).