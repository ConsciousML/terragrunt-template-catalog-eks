unit "slack_github_secrets" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/slack/github_secrets?ref=${values.version}"
  path   = "slack/github_secrets"

  values = {
    version          = values.version
    github_token     = values.github_token
    github_repo_name = values.github_repo_name
    bot_token        = values.bot_token
  }
}
