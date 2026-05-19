locals {
  version   = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  vpc_cidrs = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username_catalog  = local.github_locals.github_username_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  # Tailscale tag assigned to CI runner devices joining via WIF
  ci_tag = "tag:ci"
}

unit "acl" {
  source = "git::git@github.com:${local.github_username_catalog}/${local.github_repo_name_catalog}.git//units/eks/addons/tailscale/acl?ref=${local.version}"
  path   = "tailscale/acl"

  values = {
    version = local.version
    acl = jsonencode({
      tagOwners = {
        # CI needs to create OAuth with "tag:k8s-operator"
        (local.ci_tag)     = []
        "tag:k8s-operator" = [(local.ci_tag)]
        "tag:k8s"          = ["tag:k8s-operator"]
      }
      autoApprovers = {
        routes = {
          for cidr in values(local.vpc_cidrs) : cidr => ["tag:k8s-operator", "tag:k8s"]
        }
      }
    })
    overwrite_existing_content = false
    reset_acl_on_destroy       = true
  }
}

stack "tailscale_wif" {
  source = "github.com/${local.github_username_catalog}/${local.github_repo_name_catalog}//stacks/tailscale_wif?ref=${local.version}"
  path   = "tailscale_wif"

  values = {
    version          = local.version
    github_username  = local.github_username_catalog
    github_repo_name = local.github_repo_name_catalog
    github_token     = get_env("GITHUB_TOKEN")
    issuer           = "https://token.actions.githubusercontent.com"
    scopes           = ["all"]
    ci_tag           = local.ci_tag
  }
}
