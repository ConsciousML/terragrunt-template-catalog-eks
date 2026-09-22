#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Uses git ls-files so an untracked local lock file doesn't pass
missing=0
while read -r terragrunt_file; do
  lock="$(dirname "$terragrunt_file")/.terraform.lock.hcl"
  if ! git ls-files --error-unmatch "$lock" >/dev/null 2>&1; then
    echo "missing: $lock" >&2
    missing=1
  fi
done < <(git ls-files 'units/**/terragrunt.hcl' 'units/*/terragrunt.hcl')

if (( missing )); then
  echo "Generate them, see https://eks-forge.readthedocs.io/latest/docs/iac/reproducibility/" >&2
  exit 1
fi
