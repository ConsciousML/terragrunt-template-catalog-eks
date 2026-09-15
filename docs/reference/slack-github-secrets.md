{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Slack GitHub Secrets Bootstrap

The [`slack` stack](../../stacks/slack/), deployed by the [`slack/gh_secret` pipeline](../../pipelines/bootstrap/slack/gh_secret/), pushes `SLACK_BOT_TOKEN` into this repository's GitHub Actions secrets, so CI-driven environments can inject it into Alertmanager without managing the value by hand. Environment-independent, run once.

For setup steps, read the [catalog bootstrap guide](/docs/quickstart/bootstrap/slack).

## Modules

| Name | Unit | Module |
|------|------|--------|
| `slack_github_secrets` | [`units/slack/github_secrets`](../../units/slack/github_secrets/) | [`modules/github_secrets`](../../modules/github_secrets/) |

## Inputs

| Name | Description | Type | Default | Required |
|------|------|------|---------|----------|
| `github_token` | GitHub personal access token with `repo` permissions. | `string` | - | Yes |
| `github_repo_name` | GitHub repository name where `SLACK_BOT_TOKEN` is stored. | `string` | - | Yes |
| `bot_token` | Slack bot token with `channels:read`, `channels:manage`, `channels:join` scopes. | `string` | - | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `secrets_created` | List of GitHub secrets that were created. |
