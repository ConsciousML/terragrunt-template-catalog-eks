{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Bootstrap Pipelines

EKS Forge's [advanced features](/docs/overview/#features) use multiple different tools (AWS, [Tailscale](https://tailscale.com/), [Slack](https://slack.com/intl/en-gb/), etc.). We'll need to configure each tool before deploying the infrastructure.

Some manual steps are inevitable. However, everything else is automated through [Terragrunt pipelines](.) (see the [catalog architecture](/docs/concepts/#architecture)). These pipelines deploy account-level and repository-level resources, independent of the IaC environments (`dev`, `staging`, etc.). Those environments need the bootstrap resources deployed first to function.

Follow every individual bootstrap pipeline documentation:
- **[AWS GitHub Actions Auth](aws_gh_actions_auth/README.md)**: authenticates GitHub Actions with AWS via OIDC
- **[AWS Service Quotas](aws_service_quotas/README.md)**: requests EC2 vCPU Service Quota increases so the EKS stack can allocate enough instances
- **[Setup DNS](setup_dns/README.md)**: creates a public Route53 hosted zone per environment for ACM certificate validation
- **[Slack](slack/README.md)**: registers the Slack bot token as a GitHub Actions secret so CI-deployed Alertmanager instances can send notifications to Slack
- **[Tailscale](tailscale/README.md)**: sets up the ACL policy and OAuth client for the Tailscale Kubernetes operator

**Caution**: if you want to change the code of these pipelines, read the [For Developers section](../../stacks/README.md#for-developers).