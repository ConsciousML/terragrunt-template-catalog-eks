locals {
  version  = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  vpc_cidr = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals.vpc_cidr
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
      }
      autoApprovers = {
        routes = {
          "${local.vpc_cidr}" = ["tag:k8s-operator"]
        }
      }
    })
    overwrite_existing_content = false
    reset_acl_on_destroy       = true
  }
}
