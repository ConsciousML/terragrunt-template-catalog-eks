include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//modules/acm_certificate/?ref=${values.version}"
}

dependency "route53_hosted_zone" {
  config_path = "../route53_hosted_zone"
  mock_outputs = {
    domain_name = "mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph"]
}

inputs = {
  aws_route53_zone_name = dependency.route53_hosted_zone.outputs.domain_name
}
