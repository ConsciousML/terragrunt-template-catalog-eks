{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

## Catalog Architecture

The [catalog repository](https://github.com/ConsciousML/terragrunt-template-catalog-eks) is organized into [Terraform modules, Terragrunt units, and stacks](/docs/iac/), a layered architecture where each layer builds upon the previous one.
The [`modules/`](../modules/), [`units/`](../units/), and [`stacks/`](../stacks/) directories contain these components respectively.
In the [`pipelines/`](../pipelines/) directory, you'll find all the implemented stacks, also called pipelines.
