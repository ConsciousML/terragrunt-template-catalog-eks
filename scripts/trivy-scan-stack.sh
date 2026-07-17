#!/usr/bin/env bash
# Scans only the Terraform modules Terragrunt actually rendered with real
# input values (identified by terragrunt.values.hcl + the backend.tf that
# root.hcl generates on every unit), skipping unrelated sibling modules and
# nested stack directories that get copied into .terragrunt-cache as a side
# effect of cloning each unit's source repo.
#
# Requires a stack to already be generated and initialized
# (`terragrunt stack run init`) — this script does not generate one itself.
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
  if output=$(trivy config --quiet --ignorefile "$repo_root/.trivyignore.yaml" --tf-vars "$dir/terragrunt.values.hcl" "$dir" 2>&1); then
    continue
  fi
  echo "== $dir =="
  echo "$output"
  failed=1
done

exit "$failed"
