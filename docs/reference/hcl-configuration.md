{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}
# HCL Configuration

This page lists the `.hcl` files that units and stacks read for shared values. They live under [`pipelines/`](../../pipelines/) in the catalog and under [`live/`](https://github.com/ConsciousML/terragrunt-template-live-eks/tree/main/live) in the live repository.

Units and stacks locate each file with [`find_in_parent_folders`](https://docs.terragrunt.com/reference/hcl/functions/#find_in_parent_folders), which returns the nearest file with that name above them. A file can therefore sit at a different level in each repository and still be found.

To use these values in a unit, read the [add a unit guide](/docs/iac/add-a-unit/).

## Layout

| File | Scope | Catalog path | Live path |
|------|-------|--------------|-----------|
| [`root.hcl`](#roothcl) | Shared | `pipelines/root.hcl` | `live/root.hcl` |
| [`github.hcl`](#githubhcl) | Shared | `pipelines/github.hcl` | `live/github.hcl` |
| [`dns.hcl`](#dnshcl) | Shared | `pipelines/dns.hcl` | `live/dns.hcl` |
| [`network.hcl`](#networkhcl) | Shared | `pipelines/network.hcl` | `live/network.hcl` |
| [`cluster_name.hcl`](#cluster_namehcl) | Shared | `pipelines/dev/cluster_name.hcl` | `live/cluster_name.hcl` |
| [`provider_k8s_base.hcl`](#provider_k8s_basehcl) | Shared | `pipelines/dev/provider_k8s_base.hcl` | `live/provider_k8s_base.hcl` |
| [`provider_helm.hcl`](#provider_helmhcl) | Shared | `pipelines/dev/provider_helm.hcl` | `live/provider_helm.hcl` |
| [`environment.hcl`](#environmenthcl) | Per environment | `pipelines/dev/environment.hcl` | `live/<env>/environment.hcl` |
| [`region.hcl`](#regionhcl) | Per environment | `pipelines/region.hcl` | `live/<env>/region.hcl` |
| [`cluster_name_env.hcl`](#cluster_name_envhcl) | Per stack | `pipelines/dev/eks/cluster_name_env.hcl` | `live/<env>/eks/cluster_name_env.hcl` |
| [`domains.hcl`](#domainshcl) | Per stack | `pipelines/dev/eks/domains.hcl` | `live/<env>/eks/domains.hcl` |
| [`vpc.hcl`](#vpchcl) | Per stack | `pipelines/dev/eks/vpc.hcl` | `live/<env>/eks/vpc.hcl` |
| [`version.hcl`](#versionhcl) | Catalog only | `pipelines/version.hcl` | None |

Scopes:
- **Shared**: one file read by every environment.
- **Per environment**: one file per environment, holding values that differ between environments.
- **Per stack**: one file per stack inside an environment, composing names from the shared and per-environment files.
- **Catalog only**: no live counterpart.

The catalog deploys the `dev` environment, so some files sit at a different level than in live. `region.hcl` is shared in the catalog and per environment in live. `cluster_name.hcl` and the `provider_*.hcl` files sit under `pipelines/dev/` in the catalog and at the root of `live/`.

The [bootstrap pipelines](#bootstrap) have their own files.

## Shared

### `root.hcl`

The root configuration every unit includes through `include "root"`. It loads `region.hcl`, `environment.hcl`, and `github.hcl`, and generates the backend and AWS provider.

| Name | Kind | Description |
|------|------|-------------|
| `aws_region` | Local | `region` from `region.hcl`. |
| `environment` | Local | `environment` from `environment.hcl`. |
| `environment_alias` | Local | `environment_alias` from `environment.hcl`. |
| `github_owner_catalog`, `github_repo_name_catalog` | Local | Catalog owner and repository name from `github.hcl`. |
| `github_owner_app_of_apps`, `github_repo_name_app_of_apps` | Local | App-of-apps owner and repository name from `github.hcl`. |
| `remote_state` | Block | S3 backend. Bucket `tofu-state-<account-id>-<region>-<environment>`, key `<unit-path>/tofu.tfstate`, lock table `terragrunt_lock_table`. Generates `backend.tf`. |
| `generate "provider"` | Block | AWS provider for `aws_region`. Generates `providers_aws.tf`. |
| `catalog` | Block | Points the [Terragrunt catalog](https://docs.terragrunt.com/reference/hcl/blocks/#catalog) at the catalog repository. |
| `inputs` | Attribute | Merges the `region.hcl` and `environment.hcl` locals into every unit's inputs. |

Units read its locals through `include.root.locals`.

### `github.hcl`

GitHub owners and repository names used in module sources and GitHub resources.

| Name | Description |
|------|-------------|
| `github_owner_catalog` | User or organization owning the catalog repository. |
| `github_repo_name_catalog` | Catalog repository name. |
| `github_owner_app_of_apps` | User or organization owning the app-of-apps repository. |
| `github_repo_name_app_of_apps` | App-of-apps repository name. |
| `github_owner_live` | Live only. User or organization owning the live repository. |
| `github_repo_name_live` | Live only. Live repository name. |

### `dns.hcl`

The base domain and the subdomain of each application.

| Name | Description |
|------|-------------|
| `base_domain` | Domain every environment's hosted zone is created under. |
| `subdomain_argocd` | ArgoCD subdomain. |
| `subdomain_podinfo` | Podinfo subdomain. |
| `subdomain_prometheus` | Prometheus subdomain. |
| `subdomain_alertmanager` | Alertmanager subdomain. |
| `subdomain_grafana` | Grafana subdomain. |
| `subdomain_goldilocks` | Goldilocks subdomain. |
| `subdomain_hubble` | Hubble subdomain. |

### `network.hcl`

VPC CIDR blocks and the pinned IPs of the VPC interface endpoints.

| Name | Description |
|------|-------------|
| `vpc_cidrs` | Map of environment name to VPC CIDR block. |
| `endpoint_host_offsets` | Map of AWS service to the host offset of its interface endpoint's pinned IP within each private subnet. |
| `app_param_key_map` | Map of AWS service to the key each `CiliumNetworkPolicy` consumer in the app-of-apps repository expects in `vpcEndpointCidrs`. Services without an entry, such as `ecr.api`, `ecr.dkr`, and `sts`, have no consumer. |

`vpc_cidrs` differs between repositories:

| Environment | CIDR | Catalog | Live |
|-------------|------|---------|------|
| `prod` | `10.0.0.0/16` | Yes | Yes |
| `staging` | `10.1.0.0/16` | Yes | Yes |
| `dev` | `10.2.0.0/16` | Yes | No |
| `catalog-eks-ci` | `10.3.0.0/16` | Yes | No |

The CIDR blocks must not overlap across both repositories. The live `prod` and `staging` entries must match the catalog's. The catalog's Tailscale ACL bootstrap stack auto-approves a subnet route for every CIDR in the catalog's `vpc_cidrs`, and only runs from the catalog: a CIDR changed in live alone gets no approved route until the catalog entry is updated and the [Tailscale ACL stack](/docs/reference/bootstrap/tailscale_acl) is re-applied.

:::warning
Changing an environment's CIDR block recreates its VPC and cluster.
:::

### `cluster_name.hcl`

The base EKS cluster name, shared by every environment.

| Name | Description |
|------|-------------|
| `cluster_name` | EKS cluster name, without the environment prefix. |

### `provider_k8s_base.hcl`

Shared setup for units that talk to the Kubernetes API. Included by units that also include `provider_helm.hcl`.

| Name | Kind | Description |
|------|------|-------------|
| `cluster_name_full` | Local | `cluster_name_full` from `cluster_name_env.hcl`. |
| `cluster_exists` | Local | `true` if `aws eks describe-cluster` finds the cluster, `false` on `ResourceNotFoundException`. Fails on any other error. |
| `dependency "eks_cluster"` | Block | Dependency on the `cluster` unit, with mock outputs for `init`, `plan`, `validate`, `graph`, and `destroy`. |
| `exclude` | Block | Excludes the unit from `init`, `validate`, `plan`, and `destroy` while the cluster doesn't exist. |
| `generate "provider_k8s_base"` | Block | `aws_eks_cluster` and `aws_eks_cluster_auth` data sources named `this`. Generates `provider_k8s_base.tf`. |

### `provider_helm.hcl`

The Helm provider for units that deploy Helm charts. Included alongside `provider_k8s_base.hcl`.

| Name | Kind | Description |
|------|------|-------------|
| `generate "provider_helm"` | Block | Helm provider authenticated against the cluster from the `provider_k8s_base.hcl` data sources, with an `aws eks get-token` exec fallback. Generates `provider_helm.tf`. |

## Per Environment

### `environment.hcl`

The name of the environment a deployment targets.

| Name | Description |
|------|-------------|
| `environment` | Environment name. Suffixes the state bucket and prefixes resource names, so environments don't collide. |
| `environment_alias` | Environment name exposed to Helm as `global.environment`. Lets an environment reuse another environment's Helm value overlays while keeping its own state and resource names. |

In the catalog, `environment` defaults to `dev` and `environment_alias` defaults to `environment`. The [`TG_ENVIRONMENT` and `TG_ENVIRONMENT_ALIAS`](/docs/reference/environment_variable/#tg_environment-and-tg_environment_alias) environment variables override them, as CI does with `catalog-eks-ci` and `dev`. In live, both are hardcoded per environment.

### `region.hcl`

The AWS region and Availability Zones an environment deploys to.

| Name | Description |
|------|-------------|
| `region` | AWS region. |
| `azs` | Availability Zones the VPC spans. |

:::warning
Changing `region` recreates the environment's VPC and cluster in the new region.
:::

## Per Stack

These files sit next to the stack directory (`eks/`), so every unit of the stack finds them.

### `cluster_name_env.hcl`

The full EKS cluster name, composed from `cluster_name.hcl` and `environment.hcl`.

| Name | Description |
|------|-------------|
| `environment` | `environment` from `environment.hcl`. |
| `cluster_name` | `cluster_name` from `cluster_name.hcl`. |
| `cluster_name_full` | Full cluster name: `<environment>-<cluster_name>`. |

### `domains.hcl`

Per-application domains, composed from `dns.hcl` and `environment.hcl`.

| Name | Value |
|------|-------|
| `domain_env` | `<environment>.<base_domain>` |
| `domain_env_private` | `private.<domain_env>` |
| `domain_env_public` | `public.<domain_env>` |
| `domain_private_argocd` | `<subdomain_argocd>.<domain_env_private>` |
| `domain_public_podinfo` | `<subdomain_podinfo>.<domain_env_public>` |
| `domain_private_prometheus` | `<subdomain_prometheus>.<domain_env_private>` |
| `domain_private_alertmanager` | `<subdomain_alertmanager>.<domain_env_private>` |
| `domain_private_grafana` | `<subdomain_grafana>.<domain_env_private>` |
| `domain_private_goldilocks` | `<subdomain_goldilocks>.<domain_env_private>` |
| `domain_private_hubble` | `<subdomain_hubble>.<domain_env_private>` |

### `vpc.hcl`

The full VPC name, composed from a base name and `environment.hcl`.

| Name | Description |
|------|-------------|
| `environment` | `environment` from `environment.hcl`. |
| `vpc_name` | VPC name, without the environment suffix. |
| `vpc_full_name` | Full VPC name: `<vpc_name>-<environment>`. |

## Catalog Only

### `version.hcl`

The catalog Git ref that catalog stacks pull units and modules from.

| Name | Description |
|------|-------------|
| `version` | Catalog Git ref. Bootstrap stacks use it as `?ref=` on their unit sources. Every catalog stack passes it to its units as `values.version`, which units use as `?ref=` on their module sources. |

`version` resolves to the first non-empty value of:
1. `GITHUB_HEAD_REF`, the pull request branch in GitHub Actions
2. `GITHUB_REF_NAME`, the branch or tag in GitHub Actions
3. The current git branch, or the tag when `HEAD` is detached
4. `main`

Live has no `version.hcl`. Each live stack file pins the catalog tag in its own local: `version_catalog` in the EKS stacks, `version` in the bootstrap stacks.

## Bootstrap

The bootstrap pipelines under `pipelines/bootstrap/` and `live/bootstrap/` read some shared files and their own files.

Shared files they read:
- `github.hcl`, by every bootstrap stack
- `network.hcl`, by the catalog's Tailscale ACL stack
- `dns.hcl`, by the `setup_dns` stacks through the `units/eks/route53/hosted_zone_public` unit

Their own files:

| File | Catalog path | Live path |
|------|--------------|-----------|
| `environment.hcl` | `pipelines/bootstrap/environment.hcl` | `live/bootstrap/environment.hcl` |
| `region.hcl` | Shared `pipelines/region.hcl` | `live/bootstrap/region.hcl` |
| `environment.hcl` per DNS environment | `pipelines/bootstrap/setup_dns/<dev\|ci>/environment.hcl` | `live/bootstrap/setup_dns/<staging\|prod>/environment.hcl` |
| `environment.hcl` per Slack environment | `pipelines/bootstrap/slack/channels/<dev\|ci>/environment.hcl` | `live/bootstrap/slack/channels/<staging\|prod>/environment.hcl` |
| `channels.hcl` | `pipelines/bootstrap/slack/channels.hcl` | `live/bootstrap/slack/channels.hcl` |

`pipelines/bootstrap/environment.hcl` and `live/bootstrap/environment.hcl` set `environment` to `bootstrap-catalog-eks` and `bootstrap-live-eks` respectively, which isolates the bootstrap state from the application environments. They set `environment_alias` to `dev` and `staging` respectively. `live/bootstrap/region.hcl` sets `region` only.

The `setup_dns` and `slack/channels` stacks run once per application environment. Each has its own `environment.hcl` naming the environment it targets. `find_in_parent_folders` finds it first, so these stacks ignore `bootstrap/environment.hcl`.

### `channels.hcl`

The Slack channels created for each environment's Alertmanager notifications.

| Name | Description |
|------|-------------|
| `channel_names` | Slack channel names, without the environment prefix or leading `#`. |

Each name must match the suffix after `<environment>-` of a `slack_configs[].channel` entry in the Alertmanager configuration of [`kube-prometheus-stack`'s `values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/monitoring/kube-prometheus-stack/values.yaml) in the app-of-apps repository.

