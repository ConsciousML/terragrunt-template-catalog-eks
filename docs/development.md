# Development Workflow

This guide walks you through the complete development workflow for adding new infrastructure modules to the Terragrunt Template Catalog for AWS.

## Overview

The development process has three layers:

- **Terraform Module** (`modules/`): the core infrastructure code
- **Terragrunt Unit** (`units/`): wrapper that makes the module reusable
- **Stack** (`pipelines/dev/`): iterate on your changes locally before pushing

## Step-by-Step Development Process

### Create a Feature Branch
```bash
git checkout -b add-new-module-feature
```

### Write a Terraform Module
This step is optional if your unit wraps an external registry module directly instead of an authored one, as `cluster` and `vpc` do (e.g. `tfr:///terraform-aws-modules/eks/aws`). In that case, skip straight to writing the Terragrunt unit wrapper.

Create your infrastructure [module](https://developer.hashicorp.com/terraform/language/modules) in `modules/your_module/` with the standard Terraform files:
- `main.tf`: Resource definitions
- `variables.tf`: Input variables with detailed descriptions
- `outputs.tf`: Output values (if needed)
- `providers.tf`: Provider requirements (if needed, as the [`root.hcl`](../pipelines/root.hcl) auto-creates some providers)
- `header.md`: Header documentation for `terraform-docs`
- `footer.md`: Footer documentation for `terraform-docs`

Read the [instructions](../modules/README.md#documentation) to learn more on documentation generation with `terraform-docs`.

### Create a Terragrunt Unit Wrapper
Write a [unit](https://docs.terragrunt.com/features/units/) in `units/your_module/terragrunt.hcl` that:
- References the module using `values.version` for the git ref
- Defines dependencies on other units (if needed)
- Maps unit inputs to module variables

See the [units](../units/) directory for examples.

### Wire Up a Dev Stack
Integrate your unit into the [existing EKS stack](../pipelines/dev/eks/stack/terragrunt.stack.hcl) by adding a `unit` block that references it using `${get_repo_root()}/units/unit_name` for local development:

```hcl
unit "your_module" {
  source = "${get_repo_root()}/units/your_module"
  path   = "your_module"

  values = {
    version = local.version
    # your values here
  }
}
```

### Test Your Changes
```bash
source .env
cd pipelines/dev/eks/stack/
terragrunt stack generate
terragrunt run --all init --backend-bootstrap
terragrunt run --all validate
terragrunt run --all plan
terragrunt run --all apply
```

### Create Pull Request
Once your stack works correctly, create a PR and iterate until the [CI](../.github/workflows/ci.yaml) checks pass, then merge it to `main`.

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