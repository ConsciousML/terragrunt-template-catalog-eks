{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Slack Bootstrap

In this guide, you'll set up Slack to receive alerts from your cluster once it's [deployed](/docs/quickstart/deployment/).

:::warning
This guide needs to be performed only once per repository fork before running the [deployment](/docs/quickstart/deployment/).
:::

First, [create a Slack workspace](https://slack.com/get-started#/createnew) if you don't already have one.

Alerts need to be posted by a bot, not a personal account. You'll create a Slack app for it. First, [sign in](https://slack.com/signin#/signin) to Slack. Then, go to the [Slack's app page](https://api.slack.com/apps/) and click on `Create New App`. Then, choose `From an app manifest` and click on `Continue`. In the JSON code block, paste the following:
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
`chat:write.public` lets the bot post to any channel without being invited first. `channels:read`, `channels:manage`, and `channels:join` let it create and manage the channels you'll deploy next.

Under `Workspace`, select the workspace you want to receive notifications from and click `Next`. Finally, click on `Create and Install`. Your Slack App should be created by now.

Next, we'll install the App into our workspace. Go back to the [Slack App home page](https://api.slack.com/apps) and click on `alertmanager` under `Your Apps`. Then, in the sidebar click on `OAuth & Permissions`. Below `OAuth Tokens`, click `Install to YourWorkspaceName` and approve the consent screen. You should see your bot token appear under the same section. It starts by `xoxb-`.

That token now needs to reach GitHub Actions, so CI can use it without you managing the value by hand. This bootstrap pipeline deploys a [`gh_secret` stack](gh_secret/) that adds the token to Github Actions secrets for you.

To be able to run `gh_secret`, set [`GITHUB_TOKEN`](/docs/reference/environment_variable/#github_token) and [`SLACK_BOT_TOKEN`](/docs/reference/environment_variable/#slack_bot_token) in your `.env` file.

Alerts also need somewhere to land. The [`channels` stack](channels/) creates the Slack channels your cluster posts alerts to (e.g. `dev-k8s-critical`).

Now let's deploy the pipelines. From the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog), run the following [Terragrunt commands](/docs/iac/):
```bash
source .env
cd pipelines/bootstrap/slack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

The bot is a member of each channel it creates by default, but you aren't. [Sign in](https://app.slack.com/signin#/signin) to Slack, click on your Workspace name and:
1. Click `Directories` in the sidebar, then `Channels`
2. Search for each channel name, prefixed by `dev-` (see [`channels.hcl`](channels.hcl) for the base names)
3. Click `Join` on each one

On your Slack workspace home page, under `Channels`, you should see all the `dev-` prefixed channel names.

On your repository's GitHub page, go to `Settings > Secrets and variables > Actions`. Under `Repository secrets`, you should see `SLACK_BOT_TOKEN` listed (its value stays hidden, only the name is shown). This confirms `gh_secret` deployed correctly.

For more information, read the following stack reference documentations:
- [`slack/gh_secret`](/docs/reference/bootstrap/slack_github_secrets/)
- [`slack/channels`](/docs/reference/bootstrap/slack_channels/)