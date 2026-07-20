#!/usr/bin/env bash
# We can't just run `trivy config .` over the generated pipelines/ tree: each
# unit's .terragrunt-cache clones its full source repo, so a single unit's
# cache directory contains every sibling module too, not just the one it
# actually references. Scanning naively would rescan the same modules over
# and over across units, and count vendored siblings that were never used.
#
# Instead, this scans only the Terraform modules Terragrunt actually rendered
# with real input values (identified by terragrunt.values.hcl + the backend.tf
# that root.hcl generates on every unit), skipping those unrelated sibling
# modules and nested stack directories.
#
# Requires a stack to already be generated and initialized
# (`terragrunt stack run init`). This script does not generate one itself.
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
search_root="$repo_root/pipelines"

targets=()
while IFS= read -r dir; do
  [[ -f "$dir/backend.tf" ]] && targets+=("$dir")
done < <(find "$search_root" -type f -name terragrunt.values.hcl -exec dirname {} \; | sort -u)

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "No rendered modules found under $search_root. Run 'terragrunt stack run init' first. Skipping scan."
  exit 0
fi

failed=0
for dir in "${targets[@]}"; do
  # terragrunt.values.hcl is plain tfvars-style HCL, just under a name Trivy
  # doesn't auto-detect, so we point --tf-vars at it directly to resolve real
  # input values. It only covers inputs sourced through the stack's values.*,
  # not ones hardcoded as literals directly in a unit's `inputs` block.
  if output=$(trivy config --quiet --ignorefile "$repo_root/.trivyignore.yaml" --tf-vars "$dir/terragrunt.values.hcl" "$dir" 2>&1); then
    continue
  fi
  echo "== $dir =="
  echo "$output"
  failed=1
done

exit "$failed"
