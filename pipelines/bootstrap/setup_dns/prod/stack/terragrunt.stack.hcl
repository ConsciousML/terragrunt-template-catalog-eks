locals {
  version          = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  github_username  = "ConsciousML"
  github_repo_name = "terragrunt-template-catalog-eks"
}

stack "setup_dns" {
  source = "github.com/${local.github_username}/${local.github_repo_name}//stacks/setup_dns?ref=${local.version}"
  path   = "setup_dns"
  values = {
    version = local.version
  }
}
