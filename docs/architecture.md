### Architecture

The [catalog repository](https://github.com/ConsciousML/terragrunt-template-catalog-eks) contains multiple building blocks that follow a layered architecture where each layer builds upon the previous one:
1. [Terraform module](https://developer.hashicorp.com/terraform/language/modules): a re-usable component that creates cloud resources.
2. [Terragrunt unit](https://docs.terragrunt.com/features/units/): a wrapper over a TF module. It defines a single, deployable piece of infrastructure.
3. [Terragrunt stack](https://docs.terragrunt.com/features/stacks/): a re-usable [DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph) of units.

In other words, a stack orchestrates multiple units that materialize TF modules.
The [`modules/`](../modules/), [`units/`](../units/), and [`stacks/`](../stacks/) directories contain these components respectively.
In the [`pipelines/`](../pipelines/) directory, you'll find all the implemented stacks, also called pipelines.
