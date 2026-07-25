# Slack

Registers the Slack bot token used by Alertmanager as a GitHub Actions secret, and creates the channels it posts to.

Run via [`pipelines/bootstrap/slack`](../../pipelines/bootstrap/slack/) after manually creating and installing the Slack app.

## What's Inside

- **[github_secrets](github_secrets/)**: Stores `SLACK_BOT_TOKEN`, sourced from `.env`, as a GitHub Actions secret so CI-driven environments can inject it into Alertmanager. Environment-independent, run once.
- **[channels](channels/)**: Creates the Slack channels Alertmanager's routing config sends to, one per environment, each prefixed with the environment name (e.g. `dev-k8s-critical`). Run once per environment.
