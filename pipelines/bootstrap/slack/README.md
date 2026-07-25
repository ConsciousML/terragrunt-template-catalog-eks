# Slack Bootstrap

Registers the Slack bot token as a GitHub Actions secret, and creates the channels Alertmanager posts to.

## Purpose

Run this after manually creating and installing a Slack app. There are two independent bootstrap pipelines:

- [`gh_secret`](gh_secret/): pushes `SLACK_BOT_TOKEN` into this repository's GitHub Actions secrets, so CI-driven environments can inject it into Alertmanager without managing the value by hand. Environment-independent, run **once**. `dev` reads the same value directly from local `.env` instead of going through this.
- [`channels`](channels/): creates that environment's Slack channels, prefixed with the environment name (e.g. `dev-k8s-critical`), so the same shared bot can post every environment's alerts without colliding on one channel. Run **once per environment**.

## Quick Start

### Prerequisites

Perform the [quickstart](../../../README.md#getting-started) up to `Authenticate with AWS` (included).

Create a Slack workspace at [https://slack.com/get-started#/createnew](https://slack.com/get-started#/createnew) if you don't already have one.

Create a Slack app at [https://api.slack.com/apps/new](https://api.slack.com/apps/new), choosing "From an app manifest" and your workspace, then paste:

```json
{
  "display_information": { "name": "alertmanager" },
  "features": {
    "bot_user": { "display_name": "alertmanager" }
  },
  "oauth_config": {
    "scopes": {
      "bot": [
        "chat:write",
        "chat:write.public",
        "channels:read",
        "channels:manage",
        "channels:join"
      ]
    }
  },
  "settings": {
    "org_deploy_enabled": false,
    "socket_mode_enabled": false,
    "token_rotation_enabled": false
  }
}
```

`chat:write.public` lets the bot post to any channel without being invited to it first. `channels:read`, `channels:manage`, and `channels:join` are what the `pablovarela/slack` Terraform provider's `slack_conversation` resource needs to create and manage channels (see [`units/slack/channels`](../../../units/slack/README.md)).

On the app's "OAuth & Permissions" page, below "OAuth Tokens", click "Install to <YourWorkspaceName>" and approve the consent screen.

### Configuration

Set up `GITHUB_TOKEN` and `SLACK_BOT_TOKEN` following the [environment variables guide](../../../docs/environment-variables.md).

### Deploy

From the root directory of this repository, run:

```bash
source .env
cd pipelines/bootstrap/slack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

This deploys `gh_secret` and every environment under `channels/` in one pass. Terragrunt discovers both nested stacks from this directory.

The bot is a member of each channel it creates by default, but you aren't. Join them from the Slack client:

1. Click "Directories" in the sidebar, then "Channels"
2. Search for each environment-prefixed channel name (see [`channels.hcl`](channels.hcl) for the base names)
3. Click "Join" on each one

## Module Details

See the [`units/slack`](../../../units/slack/README.md) group README for what each unit provisions and how they compose.
