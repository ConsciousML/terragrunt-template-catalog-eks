include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/github_secrets?ref=${values.version}"
}

inputs = {
  github_token     = values.github_token
  github_owner     = include.root.locals.github_username_catalog
  github_repo_name = values.github_repo_name
  secrets = {
    SLACK_BOT_TOKEN = values.bot_token
    SLACK_APP_URL   = values.app_url
  }
}
