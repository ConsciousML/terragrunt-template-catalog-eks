data "aws_caller_identity" "current" {}

locals {
  # For wildcard (*), use repo:org/repo:*
  # For specific branch, use repo:org/repo:ref:refs/heads/branch
  subject_pattern = var.github_branch == "*" ? "repo:${var.github_username}/${var.github_repo_name}:*" : "repo:${var.github_username}/${var.github_repo_name}:ref:refs/heads/${var.github_branch}"
}

resource "aws_iam_role" "github_actions" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.subject_pattern
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}
