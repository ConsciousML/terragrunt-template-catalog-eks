# Terragrunt Stacks Directory

This directory contains reusable [Terragrunt stacks](https://terragrunt.gruntwork.io/docs/features/stacks/) for deploying multiple components on AWS.

## What are Stacks?

A **stack** is a collection of units arranged in a dependency graph that can be deployed together as a complete environment.

You can think of a stack as a blueprint that defines how multiple [units](https://terragrunt.gruntwork.io/docs/features/units/) should be composed and configured to create a working infrastructure setup.

## How to Use?

**Important**: Stacks in this directory cannot be executed directly. They are templates that require input values.

To use a stack:
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

## What's Inside?

Each stack in this directory:
- Defines a DAG of units from the `units/` directory
- Specifies dependencies between units
- Accepts input values that are passed down to the units
- Cannot be run directly from this directory

## How Stacks Work?

Stacks are **templates with inputs** that require configuration values to function. They work as DAGs where:
- Each unit represents a node in the graph
- Dependencies between units create the directed edges
- Terragrunt resolves the execution order automatically
- Input values flow through the graph to configure each unit

## For Developpers
**Caution**: if you want to change the code of these pipelines, make sure to change every occurence of the following in the `stacks/` folder:
```hcl
source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/oidc_provider?ref=${values.version}"
```
by your forked repository (replacing `<your_github_username>` and `<your_forked_repo_name>`):
```hcl
source = "git::git@github.com:<your_github_username>/<your_forked_repo_name>.git//units/oidc_provider?ref=${values.version}"
```