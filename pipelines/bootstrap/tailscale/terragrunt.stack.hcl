locals {
  version  = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  vpc_cidr = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals.vpc_cidr

  github_locals    = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username  = local.github_locals.github_username
  github_repo_name = local.github_locals.github_repo_name

  # Tailscale tag assigned to CI runner devices joining via WIF
  ci_tag = "tag:ci"
}

unit "acl" {
  source = "git::git@github.com:${local.github_username}/${local.github_repo_name}.git//units/eks/addons/tailscale/acl?ref=${local.version}"
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
          "${local.vpc_cidr}" = ["tag:k8s-operator", "tag:k8s"]
        }
      }
    })
    overwrite_existing_content = false
    reset_acl_on_destroy       = true
  }
}

unit "tailscale_wif" {
  source = "git::git@github.com:${local.github_username}/${local.github_repo_name}.git//units/tailscale/workflow_identity_federation?ref=${local.version}"
  path   = "tailscale/workflow_identity_federation"

  values = {
    version = local.version
    issuer  = "https://token.actions.githubusercontent.com"
    subject = "repo:${local.github_username}/${local.github_repo_name}:*"
    scopes  = ["all"]
    tags    = [local.ci_tag]
  }
}

unit "tailscale_github_secrets" {
  source = "git::git@github.com:${local.github_username}/${local.github_repo_name}.git//units/tailscale/github_secrets?ref=${local.version}"
  path   = "tailscale/github_secrets"

  values = {
    version          = local.version
    github_token     = get_env("GITHUB_TOKEN")
    github_repo_name = local.github_repo_name
    tags             = local.ci_tag
  }
}
