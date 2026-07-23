include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/aws_secretsmanager_secret/?ref=${values.version}"
}

inputs = {
  name = "${include.root.locals.environment}-alertmanager-slack-bot"
  secret_data = {
    bot_token = values.bot_token
    app_url   = values.app_url
  }
  recovery_window_in_days = values.recovery_window_in_days
  tags                    = values.tags
}
