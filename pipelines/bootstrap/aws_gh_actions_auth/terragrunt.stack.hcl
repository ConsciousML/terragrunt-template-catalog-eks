locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version

  github_locals            = read_terragrunt_config(find_in_parent_folders("github.hcl")).locals
  github_username_catalog  = local.github_locals.github_username_catalog
  github_repo_name_catalog = local.github_locals.github_repo_name_catalog

  github_token = get_env("GITHUB_TOKEN")
}

stack "aws_gh_actions_auth" {
  source = "github.com/${local.github_username_catalog}/${local.github_repo_name_catalog}//stacks/aws_gh_actions_auth?ref=${local.version}"
  path   = "github_actions_bootstrap"
  values = {
    version          = local.version
    github_username  = local.github_username_catalog
    github_repo_name = local.github_repo_name_catalog
    github_token     = local.github_token
    iam_role_name    = "gh-terragrunt-role-catalog"
    policy_arns = [
      "arn:aws:iam::aws:policy/AdministratorAccess",
    ]
    inline_policies = [
      {
        name = "EKSFullAccess"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Sid    = "EKSFullAccess"
              Effect = "Allow"
              Action = [
                "eks:CreateCluster",
                "eks:DeleteCluster",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:UpdateClusterConfig",
                "eks:UpdateClusterVersion",
                "eks:DescribeUpdate",
                "eks:TagResource",
                "eks:UntagResource",
                "eks:ListTagsForResource",
                "eks:CreateFargateProfile",
                "eks:DeleteFargateProfile",
                "eks:DescribeFargateProfile",
                "eks:ListFargateProfiles",
                "eks:CreateNodegroup",
                "eks:DeleteNodegroup",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:UpdateNodegroupConfig",
                "eks:UpdateNodegroupVersion",
                "eks:CreateAddon",
                "eks:DeleteAddon",
                "eks:DescribeAddon",
                "eks:DescribeAddonVersions",
                "eks:ListAddons",
                "eks:UpdateAddon",
                "eks:CreateAccessEntry",
                "eks:DeleteAccessEntry",
                "eks:DescribeAccessEntry",
                "eks:ListAccessEntries",
                "eks:AssociateAccessPolicy",
                "eks:DisassociateAccessPolicy",
                "eks:ListAssociatedAccessPolicies",
                "eks:AssociateIdentityProviderConfig",
                "eks:DisassociateIdentityProviderConfig",
                "eks:DescribeIdentityProviderConfig",
                "eks:ListIdentityProviderConfigs",
                "eks:CreatePodIdentityAssociation",
                "eks:DeletePodIdentityAssociation",
                "eks:DescribePodIdentityAssociation",
                "eks:ListPodIdentityAssociations"
              ]
              Resource = "*"
            }
          ]
        })
      }
    ]
    github_branch           = "*"
    oidc_url                = "https://token.actions.githubusercontent.com"
    oidc_client_id_list     = ["sts.amazonaws.com"]
    oidc_thumbprint_list    = []
    create_oidc_provider    = false
    deploy_key_repositories = [local.github_repo_name_catalog]
    deploy_key_secret_names = ["DEPLOY_KEY_TG_CATALOG"]
    deploy_key_title        = "Terragrunt Catalog Deploy Key"
  }
}

unit "deploy_key_terraform_docs" {
  source = "git::git@github.com:${local.github_username_catalog}/${local.github_repo_name_catalog}.git//units/github/deploy_key/?ref=${local.version}"
  path   = "github/deploy_key"

  values = {
    version            = local.version
    github_token       = local.github_token
    repositories       = [local.github_repo_name_catalog]
    current_repository = local.github_repo_name_catalog
    secret_names       = ["TERRAFORM_DOCS_DEPLOY_KEY"]
    deploy_key_title   = "Terraform Docs Deploy Key"
    read_only          = false
  }
}
