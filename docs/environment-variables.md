{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Environment Variables

The reference for every environment variable used by EKS Forge.

## Prerequisite
If you haven't already, copy the example file:
```bash
cp .env.example .env
```
`.env.example` is prefilled with every variable below, pointing to the doc that explains it. You only need to fill in the values.

:::danger
Once filled in, `.env` holds sensitive credentials. Never commit it to version control.
:::

## `GITHUB_TOKEN`

This environment variable is needed for running the [GitHub Terraform provider](https://registry.terraform.io/providers/integrations/github/latest/docs).

Authenticate with the GitHub CLI first:
```bash
gh auth login --scopes "repo,admin:repo_hook"
```

Then copy the token:
```bash
gh auth token
```

Add it to your `.env` file:
```bash
export GITHUB_TOKEN=<your_token>
```

## `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`

A Tailscale OAuth client used to authenticate to the Tailscale API and provision resources.

Go to [Tailscale Trust Credentials](https://console.tailscale.com/admin/settings/trust-credentials), then:

- Click `+ Credential`
- Select `OAuth` and click `Continue`
- Select `Scopes > All Read & Write` (or for a fine-grained token: write access for DNS, Core, Policy File, OAuth, and Federated keys)
- Click `Generate credential`

Copy both values into your `.env`:
```bash
export TAILSCALE_OAUTH_CLIENT_ID=<your_client_id>
export TAILSCALE_OAUTH_CLIENT_SECRET=<your_client_secret>
```

## `SLACK_BOT_TOKEN`

**Required by**: `pipelines/bootstrap/slack/` (both `gh_secret` and `channels`) and the EKS stack's `alertmanager/aws_secret_slack_bot` unit

Credential for the Slack app that Alertmanager posts notifications through. Created by following [`pipelines/bootstrap/slack/README.md`](../pipelines/bootstrap/slack/README.md) up to installing the app to your workspace.

Copy the Bot User OAuth Token (starts with `xoxb-`) shown under "OAuth Tokens" on the app's "OAuth & Permissions" page. Add it to your `.env`:
```bash
export SLACK_BOT_TOKEN=<your-bot-token>
```

## `APP_OF_APPS_BRANCH`

**Used by**: the dev EKS stack's `argocd_app_of_apps` unit (optional)

The `argocd-app-of-apps-template` branch ArgoCD syncs from. Defaults to `main` when unset. Set it to test an app-of-apps branch without editing the stack file:
```bash
export APP_OF_APPS_BRANCH=<your-branch>
```

Unset it (or comment it out and open a new shell) once the branch is merged. CI never sets it, so it always plans against `main`.

## `AWS_REGION`

**Required by**: `.github/workflows/ci.yaml`

The AWS region where the EKS stack is deployed.

```bash
export AWS_REGION=<your-region>   # e.g. us-east-1
```

> AWS credentials themselves are not managed via `.env`. Authenticate separately with `aws configure` or an AWS profile. See [Authenticate with AWS](../README.md#authenticate-with-aws).

## `EKS_LOCAL_ADMIN_ARN`

**Required by**: `live/staging/eks/terragrunt.stack.hcl`, `live/prod/eks/terragrunt.stack.hcl`, and `.github/workflows/` in the [live repository](https://github.com/ConsciousML/terragrunt-template-live-eks), not by anything in this catalog repo

The ARN of the local IAM identity registered as a cluster admin so it can run operations locally against staging or prod (e.g. `terragrunt destroy`) when CI deployed the cluster and can't finish tearing it down itself. This catalog only provides the unit that produces it ([`units/github/secrets/eks_local_admin`](../units/github/README.md)). The live repo consumes it.

This variable is set automatically by the bootstrap pipeline, which captures the identity of whoever runs it and stores it as a GitHub Actions secret. No manual configuration is needed.

If you need to override it locally (e.g. to test with a different identity), add it to your `.env`:
```bash
export EKS_LOCAL_ADMIN_ARN=<your_arn>
```

## `BILLING_ANOMALY_MONITOR_ARN`

**Required by**: `pipelines/bootstrap/aws_billing_alerts/`

The ARN of your account's existing `SERVICE`-dimension Cost Anomaly Detection monitor, which AWS auto-creates for every account. Find it with:
```bash
aws ce get-anomaly-monitors --output json \
  --query "AnomalyMonitors[?MonitorDimension=='SERVICE'].MonitorArn | [0]"
```

Add it to your `.env`:
```bash
export BILLING_ANOMALY_MONITOR_ARN=<your_arn>
```

Leave unset only if you want the pipeline to create a new monitor instead (fails if one already exists for the same dimension).
