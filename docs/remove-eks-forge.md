{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
## Catalog Repository
### Destroy the Dev Stack
Like for `staging` and `prod`, disconnect from Tailscale before destroying, by running `tailscale down` or with the button in the Tailscale client.

Then, run the following from the root of your [catalog fork](/docs/quickstart/installation/#fork-the-eks-forge-catalog):
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack generate
terragrunt run --all destroy --non-interactive --no-stack-generate
```

### Destroy the Catalog Bootstrap
From the root of your catalog fork, destroy the [bootstrap pipelines](/docs/quickstart/bootstrap/):
```bash
source .env
cd pipelines/bootstrap
terragrunt run --all destroy --non-interactive
```

Finally, in your domain registrar, remove the NS records of the `dev` and `ci` subdomains, for the same reason as for `staging` and `prod`.
