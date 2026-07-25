unit "slack_channels" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/slack/channels?ref=${values.version}"
  path   = "slack/channels"

  values = {
    version       = values.version
    bot_token     = values.bot_token
    environment   = values.environment
    channel_names = values.channel_names
  }
}
