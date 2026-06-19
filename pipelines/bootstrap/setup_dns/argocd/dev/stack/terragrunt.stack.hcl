locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username_catalog  = local.github_locals.github_username_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog
}

stack "setup_dns_argocd" {
  source = "github.com/${local.github_username_catalog}/${local.github_repo_name_catalog}//stacks/setup_dns/argocd?ref=${local.version}"
  path   = "setup_dns_argocd"
  values = {
    version = local.version
  }
}
