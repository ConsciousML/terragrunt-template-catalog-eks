# Slack Bootstrap

Registers the Slack bot token and app URL as GitHub Actions secrets so CI-deployed Alertmanager instances can send notifications to Slack.

## Purpose

Run this **once**, after manually creating and installing a Slack app. Pushes `SLACK_BOT_TOKEN` and `SLACK_APP_URL` into this repository's GitHub Actions secrets, so CI-driven environments can inject them into Alertmanager without managing the values by hand. `dev` reads the same two values directly from local `.env` instead of going through this bootstrap.

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
    "scopes": { "bot": ["chat:write", "chat:write.public", "channels:manage"] }
  },
  "settings": {
    "org_deploy_enabled": false,
    "socket_mode_enabled": false,
    "token_rotation_enabled": false
  }
}
```

`chat:write.public` lets the bot post to any channel without being invited to it first. `channels:manage` lets it create the channels below via `conversations.create`.

On the app's "OAuth & Permissions" page, below "OAuth Tokens", click "Install to <YourWorkspaceName>" and approve the consent screen.

### Configuration

Set up `GITHUB_TOKEN`, `SLACK_BOT_TOKEN`, and `SLACK_APP_URL` following the [environment variables guide](../../../docs/environment-variables.md).

Create the channels the routing config in [`helm-kube-prometheus-stack`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-kube-prometheus-stack/values.yaml) sends to:

```bash
source .env
while read -r channel; do
  slack api conversations.create name="$channel" --token "$SLACK_BOT_TOKEN"
done < pipelines/bootstrap/slack/channels.txt
```

The bot is a member of each channel by default, but you aren't. Join them from the Slack client:

1. Click "Directories" in the sidebar, then "Channels"
2. Search for each channel name in `channels.txt`
3. Click "Join" on each one

### Deploy

From the root directory of this repository, run:

```bash
source .env
cd pipelines/bootstrap/slack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

## Module Details

See the [`units/slack`](../../../units/slack/README.md) group README for what each unit provisions and how they compose.
