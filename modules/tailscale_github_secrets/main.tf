resource "github_actions_secret" "ts_oauth_client_id" {
  repository      = var.github_repo_name
  secret_name     = "TS_OAUTH_CLIENT_ID"
  plaintext_value = var.oauth_client_id
}

resource "github_actions_secret" "ts_audience" {
  repository      = var.github_repo_name
  secret_name     = "TS_AUDIENCE"
  plaintext_value = var.audience
}
