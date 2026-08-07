locals {
  version   = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  vpc_cidrs = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_owner_catalog     = local.github_locals.github_owner_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  # Tailscale tag assigned to CI runner devices joining via WIF
  ci_tag = "tag:ci"
}

unit "acl" {
  source = "git::git@github.com:${local.github_owner_catalog}/${local.github_repo_name_catalog}.git//units/eks/addons/tailscale/acl?ref=${local.version}"
  path   = "eks/addons/tailscale/acl"

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
