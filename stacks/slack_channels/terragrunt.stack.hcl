unit "slack_channels" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/slack/channels?ref=${values.version}"
  path   = "slack/channels"

  values = {
    version       = values.version
    bot_token     = values.bot_token
    environment   = values.environment
    channel_names = values.channel_names
  }
}
