# Continuous Integration (CI)

## Overview

The [CI](../.github/workflows/ci.yaml) automatically validates Terragrunt configurations on every pull request.

It ensures the code is well-formed before merging.

## How It Works

The [CI](../.github/workflows/ci.yaml) consists of three main jobs:

### 1. Draft PR Check
Runs first on every PR event and fails immediately if the PR is in draft mode. This prevents all downstream jobs from running until the PR is marked as ready for review.

### 2. Code Quality Checks
Runs automatically on every PR:
- **Format validation**: ensures Terragrunt (TG) and Terraform (TF) files are properly formatted
- **Linting**: validates configuration syntax and best practices with TFLint
- **Security scanning**: checks for security issues and vulnerabilities with TFSec
- **Terragrunt validation**: ensures the TF and TG files have valid syntax
- **Plan**: verifies infrastructure changes without applying them

**Note**: Read the [pre-commit configuration](../.pre-commit-config.yaml) to learn more about the run checks.

### 3. Documentation Generation
Uses `terraform-docs` to automatically generate `README.md` in each terraform module in `modules/`.

If you create new Terraform modules in `modules/`, read the [documentation instructions](../modules/README.md#documentation)

## Setup
### Initial Setup
Follow the [bootstrap guide](../pipelines/bootstrap/README.md) once per repository fork.

If applicable, in `.github/workflows/ci.yaml`, change `TG_STACK_PATH` to the relative path of the directory containing the Terragrunt Stack you want to test:
```yaml
env:
  TG_STACK_PATH: pipelines/dev/eks
```

This runs the same checks as CI locally, preventing CI failures.

## Using the CI

### Standard PR Workflow
1. Create a branch with your changes
2. Push to GitHub and open a pull request (must not be in draft mode)
3. The `code-quality-checks` job runs automatically
4. Address any failures and push fixes

## Troubleshooting
If you have a IAM Role error, in the [AWS GitHub Actions Auth bootstrap stack](../pipelines/bootstrap/aws_gh_actions_auth/README.md#configuration) update the `policy_arns` so Terragrunt can run in GitHub Actions and deploy the bootstrap pipeline following the [deploy section](../pipelines/bootstrap/aws_gh_actions_auth/README.md#deploy).

If you don't know what `arns` you need yet and some are missing, you will get an error in the [CI](../.github/workflows/ci.yaml) in the `code-quality-checks` job.

## Tips
- Failed workflows don't cancel automatically to prevent state corruption
- Do not cancel the CI manually as this will generate state locks.