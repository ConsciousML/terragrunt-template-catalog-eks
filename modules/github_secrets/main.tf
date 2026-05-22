resource "github_actions_secret" "this" {
  for_each = var.secrets

  repository      = var.github_repo_name
  secret_name     = each.key
  plaintext_value = each.value
}
