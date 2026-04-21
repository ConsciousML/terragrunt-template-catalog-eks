# The hosted zone name you've used in the `pipelines/bootstrap/setup_dns` Terragrunt pipeline
variable "aws_route53_zone_name" {
  description = "The name of the AWS Route53 Zone (i.e argocd.yourdomain.com)"
  type        = string
}