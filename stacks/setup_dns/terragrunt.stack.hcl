unit "route53_hosted_zone" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/eks/route53_hosted_zone?ref=${values.version}"
  path   = "eks/route53_hosted_zone"

  values = {
    version = values.version
    name    = values.domain_name
    comment = "Managed by Terraform"
  }
}
