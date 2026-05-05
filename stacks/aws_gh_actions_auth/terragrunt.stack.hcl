unit "github_oidc_provider" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/github/oidc_provider?ref=${values.version}"
  path   = "github/oidc_provider"

  values = {
    version         = values.version
    url             = values.oidc_url
    client_id_list  = values.oidc_client_id_list
    thumbprint_list = values.oidc_thumbprint_list
    create          = values.create_oidc_provider
  }
}

unit "iam_role_github_actions" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/github/iam_role?ref=${values.version}"
  path   = "github/iam_role"

  values = {
    version          = values.version
    name             = values.iam_role_name
    github_username  = values.github_username
    github_repo_name = values.github_repo_name
    github_branch    = values.github_branch
    inline_policies  = values.inline_policies
  }
}

unit "iam_policies" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/github/iam_policies?ref=${values.version}"
  path   = "github/iam_policies"

  values = {
    version     = values.version
    policy_arns = values.policy_arns
  }
}

unit "github_secrets" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/github/secrets?ref=${values.version}"
  path   = "github/secrets"

  values = {
    version          = values.version
    github_token     = values.github_token
    github_repo_name = values.github_repo_name
  }
}

unit "deploy_key" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/github/deploy_key?ref=${values.version}"
  path   = "github/deploy_key"

  values = {
    version            = values.version
    github_token       = values.github_token
    repositories       = values.deploy_key_repositories
    current_repository = values.github_repo_name
    secret_names       = values.deploy_key_secret_names
    deploy_key_title   = values.deploy_key_title
    read_only          = true
  }
}
