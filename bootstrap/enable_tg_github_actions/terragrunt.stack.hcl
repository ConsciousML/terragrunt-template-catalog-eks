locals {
  version = "main"

  github_repo_name = "terragrunt-template-catalog-eks"
  github_token     = get_env("TF_VAR_github_token")
}

stack "enable_tg_github_actions" {
  source = "github.com/ConsciousML/${local.github_repo_name}//stacks/enable_tg_github_actions?ref=${local.version}"
  path   = "github_actions_bootstrap"
  values = {
    version          = local.version
    github_username  = "ConsciousML"
    github_repo_name = local.github_repo_name
    github_token     = local.github_token
    iam_role_name    = "gh-terragrunt-role-catalog"
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
      "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
      "arn:aws:iam::aws:policy/IAMFullAccess",
      "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
      "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
      "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
      "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
    ]
    github_branch           = "*"
    oidc_url                = "https://token.actions.githubusercontent.com"
    oidc_client_id_list     = ["sts.amazonaws.com"]
    oidc_thumbprint_list    = []
    create_oidc_provider    = false
    deploy_key_repositories = [local.github_repo_name]
    deploy_key_secret_names = ["DEPLOY_KEY_TG_CATALOG"]
    deploy_key_title        = "Terragrunt Catalog Deploy Key"
  }
}

unit "deploy_key_terraform_docs" {
  source = "git::git@github.com:ConsciousML/${local.github_repo_name}.git//units/deploy_key/?ref=${local.version}"
  path   = "terraform_docs_deploy_key"

  values = {
    version            = local.version
    github_token       = local.github_token
    repositories       = [local.github_repo_name]
    current_repository = local.github_repo_name
    secret_names       = ["TERRAFORM_DOCS_DEPLOY_KEY"]
    deploy_key_title   = "Terraform Docs Deploy Key"
    read_only          = false
  }
}
