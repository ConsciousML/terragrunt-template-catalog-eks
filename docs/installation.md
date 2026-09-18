{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

# Installation

## Fork the EKS Forge Catalog 
EKS Forge is a toolkit containing multiple [repository templates](/docs/architecture/), each with their own responsibilities.
They're meant to be forked and extended.

To get started, you'll fork the catalog, a collection of [Terraform](https://developer.hashicorp.com/terraform) modules and [Terragrunt](https://docs.terragrunt.com/getting-started/terminology/#terragrunt) pipelines, re-usable across multiple environments (`dev`, `staging`, and `prod`):

### Private Fork
For creating a private repository, go to the [catalog home page](https://github.com/ConsciousML/terragrunt-template-catalog-eks) and:
1. click on `Use this template` in the top-right corner.
2. select `Create a new repository`
3. choose a repository name
4. under `Configuration`, click to the drop down next to `Choose visibility` and click on `Private`
5. click on `Create repository`

### Public Fork
For creating a public repository, go to the [catalog home page](https://github.com/ConsciousML/terragrunt-template-catalog-eks) and:
1. click on the `Fork` button
2. change the repository name if needed
3. click on `Create fork`

## Install the CLI Tools
Clone your fork, and `cd` at the root of the repository.

You'll use multiple CLI tools to deploy and operate EKS Forge.
Luckily, the catalog comes with a [mise-en-place](https://mise.jdx.dev/) configuration that allows you to install them all effortlessly.

Let's start by installing `mise`:
```bash
curl https://mise.run | MISE_VERSION=v2026.4.0 sh
```

All the tools are pinned to a specific version in [`mise.toml`](../mise.toml) and [`mise.local.toml`](../mise.local.toml) files.
Run the following command to install them all at once:
```bash
mise trust
mise install
```

Finally, run the following to automatically activate mise when starting a shell:
- For `zsh`: 
```bash
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc && source ~/.zshrc
```
- For `bash`:
```bash
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && source ~/.bashrc
```

For a different shell type, use the [`mise activate` reference](https://mise.jdx.dev/cli/activate.html).

:::warning
`mise` installed tools are not available system-wise by default.
You'll need to be inside your repository directory to have them loaded in your context.
More information in the [mise shims documentation](https://mise.jdx.dev/dev-tools/shims.html)
:::