resource "github_actions_secret" "aws_region" {
  repository      = var.github_repo_name
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "aws_role_arn" {
  repository      = var.github_repo_name
  secret_name     = "AWS_ROLE_ARN"
  plaintext_value = var.aws_role_arn
}