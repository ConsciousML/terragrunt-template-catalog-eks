# Development Workflow

This guide walks you through the complete development workflow for adding new infrastructure modules to the Terragrunt Template Catalog for AWS.

## Overview

The development process follows a structured approach with these layers:

1. **Terraform Module** (`modules/`): The core infrastructure code
2. **Terragrunt Unit** (`units/`): Wrapper that makes the module reusable
3. **Local Stack** (`examples/stacks/*/local/`): Test your changes locally before publishing
4. **Remote Stack** (`stacks/`) *(Optional)*: Parameterized stack for reuse across multiple live repositories

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
Create a local stack in `examples/stacks/your_stack/local/terragrunt.stack.hcl` that:
- References units using `${get_repo_root()}/units/unit_name` for local development
- Combines multiple units into a cohesive infrastructure deployment
- Provides concrete configuration values for testing
- Uses automatic version detection:

```hcl
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
    # your concrete values here
  }
}
```

### 5. Test Your Changes
```bash
cd examples/stacks/your_stack/local
terragrunt stack generate
terragrunt stack run validate
terragrunt stack run plan
terragrunt stack run apply
```

### 6. Create Pull Request
Once your stack works correctly, create a PR and merge it to `main`.

### 7. (Optional) Create a Reusable Remote Stack
If you plan to use this stack across multiple live repositories with different configurations, create a parameterized stack in `stacks/your_stack/terragrunt.stack.hcl` (see [stacks/vpc/terragrunt.stack.hcl](../stacks/vpc/terragrunt.stack.hcl) as an example):
- References units using git URLs with `ref=${values.version}`
- Accepts parameters via `values.*` instead of hardcoded values
- Can be instantiated multiple times with different configurations

**Note**: If you only need this stack in one live repository, you can skip this step and implement the stack directly in the live repo itself (mirroring the structure from `stacks/`). This makes the development process simpler.

## Practical Example

Here's how the subnet module was developed and integrated into a VPC stack by following the workflow:

### 1. Terraform Modules
Created the base infrastructure code:
- **VPC Module** → [modules/vpc/](../modules/vpc/) with [main.tf](../modules/vpc/main.tf), [variables.tf](../modules/vpc/variables.tf), [providers.tf](../modules/vpc/providers.tf), and [outputs.tf](../modules/vpc/output.tf)
- **Subnet Module** → [modules/subnet/](../modules/subnet/) with [main.tf](../modules/subnet/main.tf), [variables.tf](../modules/subnet/variables.tf), [providers.tf](../modules/subnet/providers.tf), and [outputs.tf](../modules/subnet/outputs.tf)

### 2. Terragrunt Units
Wrapped the modules in Terragrunt units:
- **VPC Unit** → [units/vpc/terragrunt.hcl](../units/vpc/terragrunt.hcl)
- **Subnet Unit** → [units/subnet/terragrunt.hcl](../units/subnet/terragrunt.hcl) with dependency on VPC unit to get the VPC ID

### 3. Local Stack for Testing
Created [examples/stacks/vpc/local/terragrunt.stack.hcl](../examples/stacks/vpc/local/terragrunt.stack.hcl) with:
- Local references using `${get_repo_root()}/units/*`
- Concrete values for VPC (CIDR: 10.0.0.0/16) and Subnet (CIDR: 10.0.1.0/24, AZ: eu-west-3a)
- Automatic version detection for the current branch

### 4. Testing Commands

```bash
cd examples/stacks/vpc/local
terragrunt stack generate
terragrunt stack run validate
terragrunt stack run plan
terragrunt stack run apply
terragrunt stack run destroy
```

### 5. (Optional) Remote Stack
Created [stacks/vpc/terragrunt.stack.hcl](../stacks/vpc/terragrunt.stack.hcl) with:
- Git URLs for unit sources
- Parameterized values (`values.cidr_block_vpc`, `values.cidr_block_subnet`, `values.zone`)
- Can be reused across multiple live repositories with different configurations
- If implementing directly in a live repo, mirror this structure but customize for your environment

## Integrate In Production
Next, tag the latest commit on main:
```bash
#replace with your version
export YOUR_GIT_TAG=v0.0.1

git checkout main
git tag $YOUR_GIT_TAG 
git push origin $YOUR_GIT_TAG
```

Finally, integrate your modification in the [terragrunt-template-live-aws](https://github.com/ConsciousML/terragrunt-template-live-aws) repository inside the appropriate environment.