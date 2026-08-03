# Terragrunt Units Directory

This directory contains reusable [Terragrunt units](https://terragrunt.gruntwork.io/docs/features/units/) for deploying AWS infrastructure.

Each unit represents a single piece of infrastructure that can be composed together to create complete stacks.

## What are Units?

A **unit** is a directory with a `terragrunt.hcl` file, wrapping a single Terraform module. Units combine into [stacks](https://terragrunt.gruntwork.io/docs/features/stacks/) to form complete environments.

## What's Inside?
Each unit:
- References a corresponding Terraform module in `modules/`
- Defines input variables using the `values.*` pattern
- Manages dependencies on other units
- Follows environment-specific naming conventions

## How to Use?
See the [stacks directory](../stacks/) for how units are used.