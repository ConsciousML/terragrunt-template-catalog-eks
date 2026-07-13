# Continuous Integration (CI)

## Overview

The [CI](../.github/workflows/ci.yaml) automatically validates Terragrunt configurations on every pull request.

It ensures the code is well-formed before merging.

## How It Works

The [CI](../.github/workflows/ci.yaml) consists of four jobs, run in sequence:

### Draft PR Check
Runs first on every PR event and fails immediately if the PR is in draft mode. This prevents all downstream jobs from running until the PR is marked as ready for review.

### Documentation Generation
Uses `terraform-docs` to automatically generate `README.md` in each terraform module in `modules/`, committing and pushing any changes back to the PR branch.

If you create new Terraform modules in `modules/`, read the [documentation instructions](../modules/README.md#documentation).

### Check Docs Changes
Fails fast if the previous job pushed a new commit, so the workflow re-triggers on that commit instead of testing a stale one. Seeing this job fail with "terraform-docs created a new commit" is expected, not a bug.

### Code Quality Checks
Runs the pre-commit checks, then `terragrunt plan`:
- **Format validation**: ensures Terragrunt (TG) and Terraform (TF) files are properly formatted
- **Linting**: validates configuration syntax and best practices with TFLint
- **Security scanning**: checks for security issues and vulnerabilities with TFSec
- **Terragrunt validation**: ensures the TF and TG files have valid syntax
- **Plan**: verifies infrastructure changes without applying them

**Note**: Read the [pre-commit configuration](../.pre-commit-config.yaml) to learn more about the run checks.

## Setup
### Initial Setup
Follow the [bootstrap guide](../pipelines/bootstrap/README.md) once per repository fork.

If applicable, in `.github/workflows/ci.yaml`, change `TG_STACK_PATH` to the relative path of the directory containing the Terragrunt Stack you want to test:
```yaml
env:
  TG_STACK_PATH: pipelines/dev/eks/stack
```

Set up [pre-commit hooks](../README.md#pre-commit-setup-recommended) to run the same checks locally, catching issues before you push.

## Using the CI
1. Create a branch with your changes
2. Push to GitHub and open a pull request (must not be in draft mode)
3. The `code-quality-checks` job runs automatically
4. Address any failures and push fixes

## Tips
- Do not cancel the CI manually as this will generate state locks.