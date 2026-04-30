locals {
  version  = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  vpc_cidr = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals.vpc_cidr

  # GitHub repo that CI runs from — update these when forking
  github_user      = "ConsciousML"
  github_repo_name = "terragrunt-template-catalog-eks"

  # Tailscale tag assigned to CI runner devices joining via WIF
  ci_tag = "tag:ci"
}

unit "acl" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/eks/addons/tailscale/acl?ref=${local.version}"
  path   = "tailscale/acl"

  values = {
    version = local.version
    acl = jsonencode({
      tagOwners = {
        "tag:k8s-operator" = []
        "tag:k8s"          = ["tag:k8s-operator"]
        (local.ci_tag)     = []
      }
      autoApprovers = {
        routes = {
          "${local.vpc_cidr}" = ["tag:k8s-operator", "tag:k8s"]
        }
      }
    })
    overwrite_existing_content = false
    reset_acl_on_destroy       = true
  }
}

unit "tailscale_wif" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/tailscale_wif?ref=${local.version}"
  path   = "tailscale/wif"

  values = {
    version = local.version
    issuer  = "https://token.actions.githubusercontent.com"
    subject = "repo:${local.github_user}/${local.github_repo_name}:*"
    #scopes  = ["devices:core", "auth_keys", "oauth_keys", "dns"]
    scopes = ["all"]
    tags   = [local.ci_tag]
  }
}

unit "tailscale_github_secrets" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/tailscale_github_secrets?ref=${local.version}"
  path   = "tailscale/github_secrets"

  values = {
    version          = local.version
    github_token     = get_env("GITHUB_TOKEN")
    github_repo_name = local.github_repo_name
    tags             = local.ci_tag
  }
}
