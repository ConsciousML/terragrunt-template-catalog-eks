locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals    = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username  = local.github_locals.github_username
  github_repo_name = local.github_locals.github_repo_name
}

stack "setup_dns" {
  source = "github.com/${local.github_username}/${local.github_repo_name}//stacks/setup_dns?ref=${local.version}"
  path   = "setup_dns"
  values = {
    version = local.version
  }
}
