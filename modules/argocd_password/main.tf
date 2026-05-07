resource "random_password" "this" {
  length           = var.length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "this" {
  name                    = var.secret_name
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    plaintext   = random_password.this.result
    bcrypt_hash = bcrypt(random_password.this.result)
  })
}
