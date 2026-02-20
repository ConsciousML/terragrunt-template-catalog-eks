#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "main" {
  cidr_block         = var.cidr_block
  enable_dns_support = var.enable_dns_support
  tags               = var.tags
}