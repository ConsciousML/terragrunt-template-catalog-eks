output "arn" {
  description = "The ARN of the OIDC provider (used in IAM role trust policies)"

  # If created the resource, output its arn. Otherwise, output the arn of the data source
  value = var.create ? aws_iam_openid_connect_provider.github_actions[0].arn : data.aws_iam_openid_connect_provider.github_actions[0].arn
}
