# Development Workflow

This guide walks you through the complete development workflow for adding new infrastructure modules to the Terragrunt Template Catalog for AWS.

## Overview

The development process follows a structured approach with these layers:

1. **Terraform Module** (`modules/`): The core infrastructure code
2. **Terragrunt Unit** (`units/`): Wrapper that makes the module reusable
3. **Stack** (`pipelines/examples/stacks/`): Test your changes locally before pushing

## Step-by-Step Development Process
Read the step-by-step process and then read the [practical example](#practical-example).

### 1. Create a Feature Branch
```bash
git checkout -b add-new-module-feature
```

### 2. Write the Terraform Module
Create your infrastructure module in `modules/your_module/` with the standard Terraform files:
- `main.tf`: Resource definitions
- `variables.tf`: Input variables with detailed descriptions
- `outputs.tf`: Output values (if needed)
- `providers.tf`: Provider requirements
- `header.md`: Header documentation for `terraform-docs`
- `footer.md`: Footer documentation for `terraform-docs`

Read the [instructions](../modules/README.md#documentation) to learn more on documentation generation with `terraform-docs`.

### 3. Create a Terragrunt Unit Wrapper
Write a terragrunt wrapper in `units/your_module/terragrunt.hcl` that:
- References the module using `values.version` for the git ref
- Defines dependencies on other units (if needed)
- Maps unit inputs to module variables

### 4. Create a Local Stack for Testing
Create a stack (i.e `pipelines/examples/stacks/your_stack/terragrunt.stack.hcl`) that:
- References units using `${get_repo_root()}/units/unit_name` for local development
- Combines multiple units into a cohesive infrastructure deployment
- Provides concrete configuration values for testing
- Uses automatic version detectione:

For example:
```hcl
# pipelines/examples/stacks/your_stack/terragrunt.stack.hcl
locals {
  # Sets the reference of the source code to:
  version = coalesce(
    get_env("GITHUB_HEAD_REF", ""), # PR branch name (only set in PRs)
    get_env("GITHUB_REF_NAME", ""), # Branch/tag name
    try(run_cmd("git", "rev-parse", "--abbrev-ref", "HEAD"), ""),
    "main" # fallback
  )
}

unit "your_module" {
  source = "${get_repo_root()}/units/your_module"
  path   = "your_module"

  values = {
    version = local.version
    # your values here
  }
}
```

### 5. Test Your Changes
```bash
cd pipelines/examples/stacks/your_stack/
terragrunt stack generate
terragrunt stack run init --backend-bootstrap
terragrunt stack run validate
terragrunt stack run plan
terragrunt stack run apply
```

### 6. Create Pull Request
Once your stack works correctly, create a PR and merge it to `main`.

## Practical Example

Checkout the [practical example](https://github.com/ConsciousML/terragrunt-template-catalog-aws/blob/main/docs/development.md#practical-example) in the EKS agnostic template.

## Integrate In Production
Next, tag the latest commit on main:
```bash
#replace with your version
export YOUR_GIT_TAG=v0.0.1

git checkout main
git tag $YOUR_GIT_TAG 
git push origin $YOUR_GIT_TAG
```

Finally, integrate your modification in the [terragrunt-template-live-eks](https://github.com/ConsciousML/terragrunt-template-live-eks) repository inside the appropriate environment.