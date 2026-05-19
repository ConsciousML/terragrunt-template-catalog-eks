# Environment Variables

This document describes every environment variable used across the bootstrap pipelines, EKS stack, and Terratest suite. It is the single reference for what each variable is, how to obtain it, and which workflows require it.

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

**Required by**: `pipelines/bootstrap/tailscale/`, `pipelines/examples/stacks/eks/`, `tests/`

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

**Required by**: `tests/`

The AWS region where the EKS stack is deployed. The Terratest suite fails immediately if this is unset.

```bash
export AWS_REGION=<your-region>   # e.g. us-east-1
```

> AWS credentials themselves are not managed via `.env`. Authenticate separately with `aws configure` or an AWS profile — see [Authenticate with AWS](../README.md#authenticate-with-aws).
