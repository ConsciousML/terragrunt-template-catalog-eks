include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/slack_channels?ref=${values.version}"
}

inputs = {
  bot_token     = values.bot_token
  environment   = values.environment
  channel_names = values.channel_names
}
