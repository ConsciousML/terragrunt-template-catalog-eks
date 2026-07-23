# Slack

Registers the Slack bot token used by Alertmanager as a GitHub Actions secret.

Run via [`pipelines/bootstrap/slack`](../../pipelines/bootstrap/slack/) after manually creating and installing the Slack app.

## What's Inside

- **[github_secrets](github_secrets/)**: Stores `SLACK_BOT_TOKEN`, sourced from `.env`, as a GitHub Actions secret so CI-driven environments can inject it into Alertmanager
