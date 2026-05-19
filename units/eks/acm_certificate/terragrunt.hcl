include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/acm_certificate/?ref=${values.version}"
}

dependency "route53_hosted_zone_public" {
  config_path = "../route53/hosted_zone_public"
  mock_outputs = {
    domain_name = "mock.example.com"
    zone_id     = "MOCKZONEID123456"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  domain_name = dependency.route53_hosted_zone_public.outputs.domain_name
  zone_id     = dependency.route53_hosted_zone_public.outputs.zone_id
}
