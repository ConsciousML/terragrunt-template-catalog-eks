locals {
  version          = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
  github_username  = "ConsciousML"
  github_repo_name = "terragrunt-template-catalog-eks"
}

unit "github_oidc_provider" {
  source = "${get_repo_root()}/units/oidc_provider"
  path   = "github_oidc_provider"

  values = {
    version         = local.version
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = []
    create          = true # Set to false in subsequent repos to use existing OIDC provider
  }
}

unit "iam_role_github_actions" {
  source = "${get_repo_root()}/units/iam_role_github_actions"
  path   = "iam_role_github_actions"

  values = {
    version          = local.version
    name             = "github-actions-terragrunt-role"
    github_username  = local.github_username
    github_repo_name = local.github_repo_name
    github_branch    = "*"
  }
}

unit "iam_policies" {
  source = "${get_repo_root()}/units/iam_policies"
  path   = "iam_policies"

  values = {
    version     = local.version
    policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  }
}

unit "github_secrets" {
  source = "${get_repo_root()}/units/github_secrets"
  path   = "github_secrets"

  values = {
    version          = local.version
    github_token     = get_env("GITHUB_TOKEN")
    github_repo_name = local.github_repo_name
  }
}

unit "deploy_key" {
  source = "${get_repo_root()}/units/deploy_key"
  path   = "deploy_key"

  values = {
    version            = local.version
    github_token       = get_env("GITHUB_TOKEN")
    repositories       = [local.github_repo_name]
    current_repository = local.github_repo_name
    secret_names       = ["DEPLOY_KEY_TG_CATALOG"]
    deploy_key_title   = "Terragrunt Catalog Deploy Key"
  }
}
