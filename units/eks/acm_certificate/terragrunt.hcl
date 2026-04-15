include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/acm_certificate/?ref=${values.version}"
}

inputs = {
  aws_route53_zone_name = values.aws_route53_zone_name
}