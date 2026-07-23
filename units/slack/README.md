# Slack

Registers the Slack bot token and app URL used by Alertmanager as GitHub Actions secrets.

Run via [`pipelines/bootstrap/slack`](../../pipelines/bootstrap/slack/) after manually creating and installing the Slack app.

## What's Inside

- **[github_secrets](github_secrets/)**: Stores `SLACK_BOT_TOKEN` and `SLACK_APP_URL`, sourced from `.env`, as GitHub Actions secrets so CI-driven environments can inject them into Alertmanager
