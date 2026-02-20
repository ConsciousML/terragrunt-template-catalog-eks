resource "aws_iam_openid_connect_provider" "github_actions" {
  # If the variable create is true, create this resource
  count = var.create ? 1 : 0

  url = var.url

  client_id_list = var.client_id_list

  thumbprint_list = var.thumbprint_list

  tags = var.tags

  # AWS automatically manages thumbprints for well-known providers like GitHub Actions
  # Ignore changes to prevent perpetual drift in plans
  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}

data "aws_iam_openid_connect_provider" "github_actions" {
  # If the variable create is false, retrieve the existing resource
  count = !var.create ? 1 : 0

  url = var.url
}