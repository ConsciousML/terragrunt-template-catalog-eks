{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

## Catalog Architecture

The [catalog repository](https://github.com/ConsciousML/terragrunt-template-catalog-eks) is organized into Terraform modules, Terragrunt units, and stacks, a layered architecture where each layer builds upon the previous one:
- [`modules/`](../modules/) contains the [Terraform modules](https://developer.hashicorp.com/terraform/language/modules)
- [`units/`](../units/) contains the [Terragrunt units](/docs/iac/#units)
- [`stacks/`](../stacks/) contains generic [Terragrunt stacks](/docs/iac/#stacks) that are used across repositories

In the [`pipelines/`](../pipelines/) directory, you'll find all the implemented stacks, also called pipelines:
- [`pipelines/bootstrap`](../pipelines/bootstrap/) contains all the [bootstrap pipelines](/docs/quickstart/bootstrap/)
- [`pipelines/dev`](../pipelines/dev/) is the `dev` IaC environment deploying the [EKS stack](/docs/overview/#features) 
