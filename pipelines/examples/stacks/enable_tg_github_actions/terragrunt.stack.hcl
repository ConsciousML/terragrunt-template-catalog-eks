locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username_catalog  = local.github_locals.github_username_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog
}

unit "github_oidc_provider" {
  source = "${get_repo_root()}/units/github/oidc_provider"
  path   = "github/oidc_provider"

  values = {
    version         = local.version
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = []
    create          = true # Set to false in subsequent repos to use existing OIDC provider
  }
}

unit "iam_role_github_actions" {
  source = "${get_repo_root()}/units/github/iam_role"
  path   = "github/iam_role"

  values = {
    version          = local.version
    name             = "github-actions-terragrunt-role"
    github_username  = local.github_username_catalog
    github_repo_name = local.github_repo_name_catalog
    github_branch    = "*"
  }
}

unit "iam_policies" {
  source = "${get_repo_root()}/units/github/iam_policies"
  path   = "github/iam_policies"

  values = {
    version     = local.version
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }
}

unit "github_secrets" {
  source = "${get_repo_root()}/units/github/secrets"
  path   = "github/secrets"

  values = {
    version          = local.version
    github_token     = get_env("GITHUB_TOKEN")
    github_repo_name = local.github_repo_name_catalog
  }
}

unit "deploy_key" {
  source = "${get_repo_root()}/units/github/deploy_key"
  path   = "github/deploy_key"

  values = {
    version            = local.version
    github_token       = get_env("GITHUB_TOKEN")
    repositories       = [local.github_repo_name_catalog]
    current_repository = local.github_repo_name_catalog
    secret_names       = ["DEPLOY_KEY_TG_CATALOG"]
    deploy_key_title   = "Terragrunt Catalog Deploy Key"
  }
}
