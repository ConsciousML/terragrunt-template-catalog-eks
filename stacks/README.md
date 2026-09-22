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
Stacks build their unit sources from the `github_owner_catalog` and `github_repo_name_catalog` values:
```hcl
source = "git::git@github.com:${values.github_owner_catalog}/${values.github_repo_name_catalog}.git//units/<unit_path>?ref=${values.version}"
```
Every caller must pass both values, read from `pipelines/github.hcl`. A fork only needs to update that file to source units from itself.