include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/acm_certificate/?ref=${values.version}"
}

dependency "route53_hosted_zone_public" {
  config_path = "../hosted_zone_public"
  mock_outputs = {
    domain_name = "mock.example.com"
    zone_id     = "MOCKZONEID123456"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

locals {
  domains_hcl        = find_in_parent_folders("domains.hcl")
  domain_env_private = read_terragrunt_config(local.domains_hcl).locals.domain_env_private
  domain_env_public  = read_terragrunt_config(local.domains_hcl).locals.domain_env_public
}

inputs = {
  domain_name               = "*.${dependency.route53_hosted_zone_public.outputs.domain_name}"
  subject_alternative_names = ["*.${local.domain_env_private}", "*.${local.domain_env_public}"]
  zone_id                   = dependency.route53_hosted_zone_public.outputs.zone_id
}
