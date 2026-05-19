unit "tailscale_wif" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/tailscale/workflow_identity_federation?ref=${values.version}"
  path   = "tailscale/workflow_identity_federation"

  values = {
    version = values.version
    issuer  = values.issuer
    subject = "repo:${values.github_username}/${values.github_repo_name}:*"
    scopes  = values.scopes
    tags    = [values.ci_tag]
  }
}

unit "tailscale_github_secrets" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/tailscale/github_secrets?ref=${values.version}"
  path   = "tailscale/github_secrets"

  values = {
    version          = values.version
    github_token     = values.github_token
    github_repo_name = values.github_repo_name
    tags             = values.ci_tag
  }
}
