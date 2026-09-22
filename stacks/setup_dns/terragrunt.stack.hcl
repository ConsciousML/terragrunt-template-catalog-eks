unit "route53_hosted_zone" {
  source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/eks/route53/hosted_zone_public?ref=${values.version}"
  path   = "eks/route53/hosted_zone_public"

  values = {
    version = values.version
    comment = "Managed by Terraform"
    create  = true
  }
}
