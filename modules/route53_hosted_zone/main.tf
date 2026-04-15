resource "aws_route53_zone" "this" {
  name    = var.name
  comment = var.comment
  tags    = var.tags
}
