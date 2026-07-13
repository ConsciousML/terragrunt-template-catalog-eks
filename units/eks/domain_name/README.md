# Domain Name

Exposes the domain name of each user-facing tool as a Terraform state output, one unit per tool. Each unit is a [`modules/identity`](../../../modules/identity/) passthrough around the corresponding `domain_private_*` and `domain_public_*` locals in [`domains.hcl`](../../../pipelines/dev/eks/domains.hcl).

## What's Inside

- **[argocd](argocd/)**: private domain for ArgoCD
- **[guestbook](guestbook/)**: public domain for the guestbook app
- **[prometheus](prometheus/)**, **[alertmanager](alertmanager/)**, **[grafana](grafana/)**: private domains for the `kube-prometheus-stack` UIs

## Integration

- **[terragrunt-template-live-eks/tests](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/tests)**: Terratest reads each unit's `value` output after deploy to know which domain to poll
