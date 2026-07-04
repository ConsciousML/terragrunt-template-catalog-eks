# Reproducibility

## Why This Matters

`.terraform.lock.hcl` pins the exact provider version **and** checksum that was resolved for a unit. Without it, `init` re-resolves providers against the registry on every run, so a tag that worked yesterday can fail today if a newer provider build satisfies the same version constraint, or a build's checksum changes. Committing the lock file is what makes an old tag actually reproducible.

## The Problem with Stacks

[Vanilla Terragrunt copies `.terraform.lock.hcl`](https://docs.terragrunt.com/reference/lock-files/) from your working directory into `.terragrunt-cache` before `init`, and copies it back after. `terragrunt stack` breaks this: units are rendered into `.terragrunt-stack/<unit-path>/` first, so the copy-back lands there instead of in the unit's source directory. `.terragrunt-stack` is gitignored and fully regenerated on every `stack generate`, so any lock file Terragrunt writes there is lost the moment you regenerate. See [gruntwork-io/terragrunt#4314](https://github.com/gruntwork-io/terragrunt/issues/4314), there's no stack-aware fix for this yet.

## What to Do

Commit `.terraform.lock.hcl` directly into each unit's source directory (`units/.../`), not into the stack. `stack generate` copies the entire unit source tree into `.terragrunt-stack/`, so a lock file committed in `units/` is carried along on every regeneration and used normally from then on.

### 1. Generate the lock files

```bash
cd pipelines/dev/eks/stack
terragrunt stack run init
```

### 2. Copy them back into `units/`

Each rendered unit's lock file lives at `.terragrunt-stack/<unit-path>/.terraform.lock.hcl`. Copy it into the matching `units/<unit-path>/.terraform.lock.hcl`:

```bash
find .terragrunt-stack -name ".terraform.lock.hcl" | while read -r lock; do
  unit_path="${lock#.terragrunt-stack/}"
  unit_path="${unit_path%/.terraform.lock.hcl}"
  cp "$lock" "../../../../units/${unit_path}/.terraform.lock.hcl"
done
```

### 3. Commit

```bash
git add units/**/.terraform.lock.hcl
git commit -m "chore: pin provider lock files"
```

## Updating a Lock File

When a single unit's provider requirements change (a version bump, a new provider), you don't need to reinit the whole stack. `cd` into that unit's rendered directory and re-init directly:

```bash
cd pipelines/dev/eks/stack/.terragrunt-stack/<unit-path>
rm .terraform.lock.hcl
terragrunt init
```

`terragrunt init -upgrade` does the same without the manual `rm`.

Copy the new lock file back into `units/<unit-path>/.terraform.lock.hcl` and commit. Skipping the copy-back means the next `stack generate` falls back to the stale committed lock file and `init` fails with a checksum/version mismatch, the exact error this doc exists to prevent.

## Why Not Alternatives

- **Persisting `.terragrunt-stack` in git** (un-ignoring the lock files there, restoring them via a `before_hook`) keeps lock files scoped per environment, but adds a fragile hook and an easy-to-miss "commit immediately after `-upgrade` or it gets overwritten" step.
- **Pinning exact provider versions instead of using lock files** avoids the whole problem, but only pins the version number, not the checksum, so it drops the supply-chain guarantee lock files exist for.
