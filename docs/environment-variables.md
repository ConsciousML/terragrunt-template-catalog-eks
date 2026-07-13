# Environment Variables

This document describes every environment variable used across the bootstrap pipelines and EKS stack. It is the single reference for what each variable is, how to obtain it, and which workflows require it.

## Prerequisite
If you haven't already, copy the example file:
```bash
cp .env.example .env
```

## `GITHUB_TOKEN`

**Required by**: `pipelines/bootstrap/aws_gh_actions_auth/`

A GitHub fine-grained personal access token used to register GitHub secrets and deploy keys in the bootstrap pipeline.

Authenticate with the GitHub CLI first:
```bash
gh auth login --scopes "repo,admin:repo_hook"
```

Then copy the token:
```bash
gh auth token
```

Add it to your `.env`:
```bash
export GITHUB_TOKEN=<your_token>
```

## `TAILSCALE_OAUTH_CLIENT_ID` and `TAILSCALE_OAUTH_CLIENT_SECRET`

**Required by**: `pipelines/bootstrap/tailscale/`

A Tailscale OAuth client used to authenticate to the Tailscale API and provision resources (ACL, WIF credential, subnet router, split DNS).

Go to [Tailscale Trust Credentials](https://login.tailscale.com/admin/settings/trust-credentials), then:

- Click `+ Credential`
- Select `OAuth` and click `Continue`
- Select `Scopes > All Read & Write` (or for a fine-grained token: write access for DNS, Core, Policy File, OAuth, and Federated keys)
- Click `Generate credential`

Copy both values into your `.env`:
```bash
export TAILSCALE_OAUTH_CLIENT_ID=<your_client_id>
export TAILSCALE_OAUTH_CLIENT_SECRET=<your_client_secret>
```

## `AWS_REGION`

**Required by**: `.github/workflows/ci.yaml`

The AWS region where the EKS stack is deployed.

```bash
export AWS_REGION=<your-region>   # e.g. us-east-1
```

> AWS credentials themselves are not managed via `.env`. Authenticate separately with `aws configure` or an AWS profile. See [Authenticate with AWS](../README.md#authenticate-with-aws).

## `EKS_LOCAL_ADMIN_ARN`

**Required by**: `live/prod/eks/terragrunt.stack.hcl` and `.github/workflows/` in the [live repository](https://github.com/ConsciousML/terragrunt-template-live-eks), not by anything in this catalog repo

The ARN of the local IAM identity registered as a cluster admin so it can run operations locally against prod (e.g. `terragrunt destroy`). This catalog only provides the unit that produces it ([`units/github/secrets/eks_local_admin`](../units/github/README.md)). The live repo is what actually consumes it.

This variable is set automatically by the bootstrap pipeline, which captures the identity of whoever runs it and stores it as a GitHub Actions secret. No manual configuration is needed.

If you need to override it locally (e.g. to test with a different identity), add it to your `.env`:
```bash
export EKS_LOCAL_ADMIN_ARN=<your_arn>
```
