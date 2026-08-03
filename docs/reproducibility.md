# Reproducibility

Provider lock files (`.terraform.lock.hcl`) must be committed per unit for stacks to be reproducible.

## Generate the Lock Files

```bash
cd pipelines/dev/eks/stack
terragrunt stack run init
```

## Copy Them Back into `units/`

From the repo root, run:

```bash
make sync-lock-files
```

This runs `scripts/sync-lock-files.sh`, which copies each rendered unit's lock file at `.terragrunt-stack/<unit-path>/.terraform.lock.hcl` into the matching `units/<unit-path>/.terraform.lock.hcl`, anywhere in the repo.

## Review and Commit

Check `git diff units/` (or `git status` for newly added units) to make sure the changes make sense, then commit:

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

From the repo root, run `make sync-lock-files`, verify `git diff units/<unit-path>/.terraform.lock.hcl` shows only the expected version and checksum change, commit, and push.

## Details

### Why This Matters

`.terraform.lock.hcl` pins the exact provider version **and** checksum that was resolved for a unit. Without it, `init` re-resolves providers against the registry on every run, so a tag that worked yesterday can fail today if a newer provider build satisfies the same version constraint, or a build's checksum changes. Committing the lock file is what makes an old tag actually reproducible.

### The Problem with Stacks

[Vanilla Terragrunt copies `.terraform.lock.hcl`](https://docs.terragrunt.com/reference/lock-files/) from your working directory into `.terragrunt-cache` before `init`, and copies it back after. `terragrunt stack` breaks this: units are rendered into `.terragrunt-stack/<unit-path>/` first, so the copy-back lands there instead of in the unit's source directory.

`.terragrunt-stack` is gitignored and fully regenerated on every `stack generate`, so any lock file Terragrunt writes there is lost the moment you regenerate. See [gruntwork-io/terragrunt#4314](https://github.com/gruntwork-io/terragrunt/issues/4314). There's no stack-aware fix yet.

### Our Strategy

Commit `.terraform.lock.hcl` directly into each unit's source directory (`units/.../`), not into the stack. `stack generate` copies the entire unit source tree into `.terragrunt-stack/`, so a lock file committed in `units/` is carried along on every regeneration and used normally from then on.
