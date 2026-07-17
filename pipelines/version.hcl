locals {
  version = coalesce(
    get_env("GITHUB_HEAD_REF", ""),                                                                                                          # PR branch name (only set in PRs)
    get_env("GITHUB_REF_NAME", ""),                                                                                                          # Branch/tag name
    try(run_cmd("--terragrunt-quiet", "sh", "-c", "git symbolic-ref --short -q HEAD || git describe --tags --exact-match 2>/dev/null"), ""), # falls back to tag name when HEAD is detached
    "main"                                                                                                                                   # fallback
  )
}
