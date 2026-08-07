# Terragrunt Stacks Directory

This directory contains reusable [Terragrunt stacks](https://terragrunt.gruntwork.io/docs/features/stacks/) for deploying multiple components on AWS.

## What are Stacks?

A **stack** is a DAG of [units](https://terragrunt.gruntwork.io/docs/features/units/) from the `units/` directory, deployed together as a complete environment. Input values flow through the graph and Terragrunt resolves execution order from the declared dependencies.

Stacks in this directory are templates. They require input values and cannot be run directly from here.

## How to Use?

1. Refer to the [pipelines/dev/](../pipelines/dev/) directory for concrete implementations
2. Copy a stack that matches your needs
3. Modify the `values` block to suit your requirements
4. Run:
```bash
source .env
cd pipelines/dev/<your_stack>
terragrunt stack generate
terragrunt run --all apply --no-stack-generate
```

For understanding individual components, see the [units directory](../units/).

## For Developers
**Caution**: if you want to change the code of these pipelines, make sure to change every occurence of the following in the `stacks/` folder:
```hcl
source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/<unit_path>?ref=${values.version}"
```
by your forked repository (replacing `<github_owner>` and `<your_forked_repo_name>`):
```hcl
source = "git::git@github.com:<github_owner>/<your_forked_repo_name>.git//units/<unit_path>?ref=${values.version}"
```