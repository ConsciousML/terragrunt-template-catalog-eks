# Domain Name

Exposes the domain name of each user-facing tool as a Terraform state output, one unit per tool, so [terragrunt-template-live-eks's Terratest suite](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/tests) can read each `value` output after deploy to know which domain to poll.

Each unit is a [`modules/identity`](../../../modules/identity/) passthrough around the corresponding `domain_private_*` and `domain_public_*` locals in [`domains.hcl`](../../../pipelines/dev/eks/domains.hcl).

## What's Inside

- **[argocd](argocd/)**: private domain for ArgoCD
- **[podinfo](podinfo/)**: public domain for the podinfo sample app
- **[prometheus](prometheus/)**, **[alertmanager](alertmanager/)**, **[grafana](grafana/)**: private domains for the `kube-prometheus-stack` UIs
- **[goldilocks](goldilocks/)**: private domain for the Goldilocks dashboard
