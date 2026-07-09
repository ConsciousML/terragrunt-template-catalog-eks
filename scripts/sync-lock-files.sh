#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"

# Exclude .terragrunt-cache: Terragrunt's transient copy of the lock file, torn down during init
find "$repo_root" -path "*/.terragrunt-stack/*/.terraform.lock.hcl" -not -path "*/.terragrunt-cache/*" | while read -r lock; do
  unit_path="${lock#*/.terragrunt-stack/}"
  unit_path="${unit_path%/.terraform.lock.hcl}"
  dest="$repo_root/units/$unit_path/.terraform.lock.hcl"
  cp "$lock" "$dest"
  echo "synced: units/$unit_path/.terraform.lock.hcl"
done
