#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
failed=()

# Exclude .terragrunt-cache: Terragrunt's transient copy of the lock file, torn down during init
while read -r lock; do
  unit_path="${lock##*/.terragrunt-stack/}"
  unit_path="${unit_path%/.terraform.lock.hcl}"
  dest="$repo_root/units/$unit_path/.terraform.lock.hcl"
  if cp "$lock" "$dest" 2>/dev/null; then
    echo "synced: units/$unit_path/.terraform.lock.hcl"
  else
    echo "failed: units/$unit_path/.terraform.lock.hcl (from ${lock#"$repo_root"/})" >&2
    failed+=("units/$unit_path")
  fi
done < <(find "$repo_root" -path "*/.terragrunt-stack/*/.terraform.lock.hcl" -not -path "*/.terragrunt-cache/*")

if ((${#failed[@]})); then
  echo "${#failed[@]} lock file(s) failed to sync:" >&2
  printf '  %s\n' "${failed[@]}" >&2
  exit 1
fi
