# Development Workflow

This guide walks you through the complete development workflow for adding new infrastructure modules to the Terragrunt Template Catalog for AWS.

## Overview

The development process follows a structured approach with these layers:

1. **Terraform Module** (`modules/`): The core infrastructure code
2. **Terragrunt Unit** (`units/`): Wrapper that makes the module reusable
3. **Stack** (`pipelines/dev/`): Iterate on your changes locally before pushing

## Step-by-Step Development Process

### 1. Create a Feature Branch
```bash
git checkout -b add-new-module-feature
```

### 2. Write a Terraform Module
Create your infrastructure module in `modules/your_module/` with the standard Terraform files:
- `main.tf`: Resource definitions
- `variables.tf`: Input variables with detailed descriptions
- `outputs.tf`: Output values (if needed)
- `providers.tf`: Provider requirements (if needed, as the [`root.hcl`](../pipelines/root.hcl) auto-creates some providers)
- `header.md`: Header documentation for `terraform-docs`
- `footer.md`: Footer documentation for `terraform-docs`

Read the [instructions](../modules/README.md#documentation) to learn more on documentation generation with `terraform-docs`.

### 3. Create a Terragrunt Unit Wrapper
Write a terragrunt wrapper in `units/your_module/terragrunt.hcl` that:
- References the module using `values.version` for the git ref
- Defines dependencies on other units (if needed)
- Maps unit inputs to module variables

### 4. Wire Up a Dev Stack
Either integrate your unit into the [existing EKS stack](../pipelines/dev/eks/terragrunt.stack.hcl) or create a new stack at `pipelines/dev/your_stack/terragrunt.stack.hcl` that:
- References units using `${get_repo_root()}/units/unit_name` for local development
- Combines multiple units into an infrastructure deployment
- Provides configuration values
- Uses automatic version detection

For example:
```hcl
# pipelines/dev/your_stack/terragrunt.stack.hcl
locals {
  version = read_terragrunt_config(find_in_parent_folders("version.hcl")).locals.version
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
source .env
cd pipelines/dev/your_stack/
terragrunt stack generate
terragrunt run --all init --backend-bootstrap
terragrunt run --all validate
terragrunt run --all plan
terragrunt run --all apply
```

### 6. Create Pull Request
Once your stack works correctly, create a PR and merge it to `main`.

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