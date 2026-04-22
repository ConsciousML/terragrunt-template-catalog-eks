locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
}

stack "setup_dns" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-eks//stacks/setup_dns?ref=${local.version}"
  path   = "setup_dns"
  values = {
    version = local.version
  }
}
