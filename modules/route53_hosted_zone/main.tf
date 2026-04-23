resource "aws_route53_zone" "this" {
  count   = var.create ? 1 : 0
  name    = var.name
  comment = var.comment
  tags    = var.tags

  dynamic "vpc" {
    for_each = var.vpc_id != null ? [var.vpc_id] : []
    content {
      vpc_id = vpc.value
    }
  }
}

data "aws_route53_zone" "this" {
  count        = var.create ? 0 : 1
  name         = var.name
  private_zone = var.private_zone
}
