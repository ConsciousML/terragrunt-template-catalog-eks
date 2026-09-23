{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# Slack Bootstrap

In this guide, you'll set up Slack to receive alerts from your cluster once it's [deployed](/docs/quickstart/deployment/).

:::warning
This guide needs to be performed only once per catalog fork before running the [deployment](/docs/quickstart/deployment/).
:::

First, [create a Slack workspace](https://slack.com/get-started#/createnew) if you don't already have one.

Alerts need to be posted by a bot, not a personal account. To create a Slack app for it:
1. [Sign in](https://slack.com/signin#/signin) to Slack
2. Go to the [Slack app page](https://api.slack.com/apps/) and click `Create New App`
3. Choose `From an app manifest` and click `Continue`
4. In the JSON code block, paste the following:
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
5. Under `Workspace`, select the workspace you want to receive notifications from and click `Next`
6. Click `Create and Install`

The manifest's scopes let the bot post alerts and create the channels you'll deploy next. Your Slack app should be created by now.

Next, you'll install the app into your workspace. Go back to the [Slack app page](https://api.slack.com/apps) and click on `alertmanager` under `Your Apps`. Then, in the sidebar click on `OAuth & Permissions`. Below `OAuth Tokens`, click `Install to YourWorkspaceName` and approve the consent screen. You should see your bot token appear under the same section. It starts with `xoxb-`.

Then, add [`SLACK_BOT_TOKEN`](/docs/reference/environment_variable/#slack_bot_token) to your `.env` file.

You'll deploy two stacks:
- [`gh_secret`](gh_secret/), which adds the bot token to GitHub Actions secrets, so CI can use it without you managing the value by hand
- [`channels`](channels/), which creates the Slack channels your cluster posts alerts to (e.g. `dev-k8s-critical`)

Now, run the following [Terragrunt commands](/docs/iac/) from the root directory of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/bootstrap/slack
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

The bot is a member of each channel it creates by default, but you aren't. Click on your workspace name and:
1. Click `Directories` in the sidebar, then `Channels`
2. Search for each channel name, prefixed by `dev-` and `catalog-eks-ci-` (see [`channels.hcl`](channels.hcl) for the base names)
3. Click `Join` on each one

On your Slack workspace home page, under `Channels`, you should see all the `dev-` and `catalog-eks-ci-` prefixed channel names.

Finally, list the GitHub Actions secrets of your fork:
```bash
gh secret list
```

You should see `SLACK_BOT_TOKEN`. This confirms `gh_secret` deployed correctly.

For more information, read the following stack reference documentation:
- [`slack/gh_secret`](/docs/reference/bootstrap/slack_github_secrets/)
- [`slack/channels`](/docs/reference/bootstrap/slack_channels/)