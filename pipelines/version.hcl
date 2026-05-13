locals {
  #version = coalesce(
  #  get_env("GITHUB_HEAD_REF", ""), # PR branch name (only set in PRs)
  #  get_env("GITHUB_REF_NAME", ""), # Branch/tag name
  #  try(run_cmd("git", "rev-parse", "--abbrev-ref", "HEAD"), ""),
  #  "main" # fallback
  #)
  version = "a8947f8"
}
