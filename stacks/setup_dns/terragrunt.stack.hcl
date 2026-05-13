unit "hosted_zone_public" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/eks/route53/hosted_zone_public?ref=${values.version}"
  path   = "eks/route53/hosted_zone_public"

  values = {
    version = values.version
    comment = "Managed by Terraform"
    create  = true
  }
}
