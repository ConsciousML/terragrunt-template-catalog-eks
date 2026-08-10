include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/aws_secretsmanager_secret/?ref=${values.version}"
}

inputs = {
  name = "${include.root.locals.environment}-alertmanager-slack-bot"
  # Key here (bot_token) must match the remoteProperty value in
  # charts/external-secrets-operator/secret-sync/alertmanager-secrets-values.yaml (argocd-app-of-apps-template repo),
  # which pulls it into the alertmanager-slack-bot Secret Alertmanager mounts.
  secret_data = {
    bot_token = values.bot_token
  }
  recovery_window_in_days = values.recovery_window_in_days
  tags                    = values.tags
}
