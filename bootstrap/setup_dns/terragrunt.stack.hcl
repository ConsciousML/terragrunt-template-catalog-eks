locals {
  # Sets the reference of the source code to:
  version = coalesce(
    get_env("GITHUB_HEAD_REF", ""), # PR branch name (only set in PRs)
    get_env("GITHUB_REF_NAME", ""), # Branch/tag name
    try(run_cmd("git", "rev-parse", "--abbrev-ref", "HEAD"), ""),
    "main" # fallback
  )
}

stack "setup_dns" {
  source = "github.com/ConsciousML/terragrunt-template-catalog-eks//stacks/setup_dns?ref=${local.version}"
  path   = "setup_dns"

  values = {
    version     = local.version
    domain_name = "argocd.axelmendoza.com"
  }
}
