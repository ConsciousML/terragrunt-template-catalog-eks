resource "aws_route53_zone" "this" {
  count   = var.create ? 1 : 0
  name    = var.name
  comment = var.comment
  tags    = var.tags
}

data "aws_route53_zone" "this" {
  count        = var.create ? 0 : 1
  name         = var.name
  private_zone = false
}
