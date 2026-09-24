{/* This doc is aggregated into the EKS Forge documentation site: https://eks-forge.readthedocs.io/latest/. It is not meant to be read directly in this repository. */}

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

This guide shows you how to add a [unit](/docs/iac/#units) to your [forked catalog](/docs/quickstart/installation/#fork-the-eks-forge-catalog), or edit an existing one, and ship it to [`staging`](/docs/iac/#staging) and [`prod`](/docs/iac/#prod). It covers AWS resources and the Kubernetes add-ons that must run before ArgoCD. For applications ArgoCD deploys, see [Applications](/docs/applications/).

First, create a branch in your forked catalog:
```bash
git checkout -b <branch>
```

If you're editing an existing unit, make your change, then:
- If it reads new `values`, continue at [Add the Unit to the Dev Stack](#add-the-unit-to-the-dev-stack).
- Otherwise, continue at [Validate in Dev](#validate-in-dev).

## Write the Unit

Pick the tab that fits your component:
- **Registry module**: an AWS resource covered by a public module.
- **Kubernetes add-on**: an add-on that must run before ArgoCD.
- **Custom module**: anything else.

<Tabs groupId="component">
<TabItem value="registry" label="Registry module">

Create `units/<group>/<name>/terragrunt.hcl`, grouping it by domain like the existing units (e.g. `units/vpc/endpoints/terragrunt.hcl` for the VPC endpoints), and include the root configuration with `expose = true`:
```hcl
# units/<group>/<name>/terragrunt.hcl

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}
```

Point `source` at the registry module. You pin the version later, in the dev stack:
```hcl
terraform {
  # e.g. tfr:///terraform-aws-modules/s3-bucket/aws?version=${values.version}
  source = "tfr:///<namespace>/<name>/<provider>?version=${values.version}"
}
```

Map the module's inputs from `values`, the per-environment settings you set in the stack file, replacing `<module-input>` with an input of the module:
```hcl
inputs = {
  <module-input> = values.<module-input> # e.g. force_destroy = values.force_destroy
}
```

For complete examples, see the [`vpc`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/vpc/vpc/terragrunt.hcl), [`cluster`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/cluster/terragrunt.hcl), and [Loki S3 `chunks`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/addons/loki/s3/chunks/terragrunt.hcl) units.

</TabItem>
<TabItem value="kubernetes" label="Kubernetes add-on">

Create `units/eks/addons/<name>/helm/terragrunt.hcl` (e.g. `units/eks/addons/cilium/helm/terragrunt.hcl`). On top of the root configuration, include the Kubernetes and Helm provider files. They add the dependency on the EKS cluster, and skip the unit while the cluster doesn't exist yet:
```hcl
# units/eks/addons/<name>/helm/terragrunt.hcl

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_helm" {
  path = find_in_parent_folders("provider_helm.hcl")
}
```

Point `source` at the catalog's `helm_release` module, pinned to the catalog version:
```hcl
terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/helm_release/?ref=${values.version}"
}
```

Make it run after `cilium_cep_restart`, so its pods start once `cilium-agent` is ready and get a CiliumEndpoint without a restart:
```hcl
dependency "cilium_cep_restart" {
  config_path  = "../../cilium/cep_restart"
  skip_outputs = true
}
```

Describe the chart in `inputs`, replacing `<release-name>`, `<chart-repository-url>`, `<chart-name>`, and `<namespace>` with your chart's details. The cluster name comes from the dependency the provider file added:
```hcl
inputs = {
  cluster_name       = dependency.eks_cluster.outputs.cluster_name
  name               = "<release-name>"          # e.g. "cilium"
  repository         = "<chart-repository-url>"  # e.g. "https://helm.cilium.io"
  chart              = "<chart-name>"            # e.g. "cilium"
  namespace          = "<namespace>"             # e.g. "kube-system"
  helm_chart_version = values.helm_chart_version
  helm_values        = values.helm_values
}
```

If you bundle the chart yourself, put it under `charts/<name>/`, drop `repository`, and set `chart = "../../charts/<name>"` (e.g. `chart = "../../charts/karpenter-ec2-node-class"`).

For complete examples, see the [`cilium`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/addons/cilium/helm/terragrunt.hcl) and [`karpenter`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/addons/karpenter/helm/terragrunt.hcl) units for upstream charts, and the [Karpenter `ec2_node_class`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/addons/karpenter/ec2_node_class/terragrunt.hcl) unit for a bundled one.

</TabItem>
<TabItem value="custom" label="Custom module">

Create the module under `modules/<name>/` (e.g. `modules/acm_certificate/`). CI generates its `README.md` from `header.md` and `footer.md`, so add both, even if `footer.md` stays empty:
```text
modules/<name>/
├── main.tf        # resources
├── variables.tf   # inputs
├── versions.tf    # required providers and their versions
├── outputs.tf     # only if other units read from it
├── providers.tf   # only if it configures a provider
├── header.md      # module title and description
└── footer.md      # extra notes, can be empty
```

Create its unit under `units/<group>/<name>/terragrunt.hcl` (e.g. `units/eks/route53/acm_certificate/terragrunt.hcl`), and point `source` at the module, pinned to the catalog version:
```hcl
# units/<group>/<name>/terragrunt.hcl

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  # e.g. "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/acm_certificate/?ref=${values.version}"
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/<name>/?ref=${values.version}"
}
```

Map your module's variables from `values`, replacing `<module-variable>` with one of them:
```hcl
inputs = {
  <module-variable> = values.<module-variable> # e.g. domain_name = values.domain_name
}
```

For complete examples, see the [`acm_certificate`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/modules/acm_certificate) module and [its unit](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/route53/acm_certificate/terragrunt.hcl), or the [`eks_addon`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/modules/eks_addon) module and [its unit](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/eks/addons/ebs_csi_driver/addon/terragrunt.hcl).

</TabItem>
</Tabs>

## Read Shared Config and Other Units' Outputs

If your unit needs shared configuration, read it from the `.hcl` files under `pipelines/`, listed in the [shared configuration reference](/docs/reference/shared_configuration/). Read what `root.hcl` already loads through `include.root.locals`. Read any other file with `find_in_parent_folders`.

Prefix resource names with the environment, so they don't collide across environments:
```hcl
locals {
  vpc_cidr = read_terragrunt_config(find_in_parent_folders("network.hcl")).locals.vpc_cidrs[include.root.locals.environment]
}

inputs = {
  name = "${include.root.locals.environment}-<name>" # e.g. "${include.root.locals.environment}-loki" for the Loki IAM role
  cidr = local.vpc_cidr
}
```

If your unit needs another unit's outputs, add a `dependency` block pointing at that unit's directory, and read its outputs in `inputs`. If it only has to run after the other unit, without reading its outputs, set `skip_outputs = true` instead. For example, the EBS CSI driver add-on reads the cluster name from `cluster`:
```hcl
# units/eks/addons/ebs_csi_driver/addon/terragrunt.hcl

dependency "cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.cluster.outputs.cluster_name
}
```

The `mock_outputs` let `plan` run before the `cluster` unit has been applied.

Add a `README.md` describing what the unit deploys and which units it depends on. For example, the EBS CSI driver's README, in `units/eks/addons/ebs_csi_driver/`:
```markdown
# EBS CSI Driver

Installs the Amazon EBS CSI Driver as an EKS managed addon, enabling `PersistentVolumeClaim`
provisioning backed by EBS volumes.

## Upstream Dependencies

- **[`units/eks/cluster`](../../cluster/)**: provides the `cluster_name` output consumed by `addon`
- **[`units/eks/addons/cilium/cep_restart`](../cilium/cep_restart/)**: `addon` depends on it so
  its pods start after `cilium-agent` is ready
```

## Add the Unit to the Dev Stack

Add a `unit` block to [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/pipelines/dev/eks/stack/terragrunt.stack.hcl). Point `source` at your unit, and set `path` to the unit's directory under `units/`, so its lock file syncs back to it in [Commit the Lock File](#commit-the-lock-file). Pick the tab that fits your component:

<Tabs groupId="component">
<TabItem value="registry" label="Registry module">

Pin the module's version as a `version_<name>` local at the top of the file, and pass it as `version`. For example, for the Loki S3 chunks bucket:
```hcl
locals {
  version_s3 = "5.15.1"
}

unit "loki_s3_chunks" {
  source = "${get_repo_root()}/units/eks/addons/loki/s3/chunks"
  path   = "eks/addons/loki/s3/chunks"

  values = {
    version = local.version_s3
  }
}
```

</TabItem>
<TabItem value="kubernetes" label="Kubernetes add-on">

Keep its `path` under `eks/addons/`. The provider files find the cluster from the `addons` directory in that `path`.

Pass `local.version` as `version`, the catalog version the stack already resolves. Pin the chart version as a `version_<name>` local, and pass it as `helm_chart_version` along with the chart's `helm_values`. The unit reads both, so the apply fails if either is missing. For example, for Cilium:
```hcl
locals {
  version_cilium = "1.20.0"
}

unit "cilium" {
  source = "${get_repo_root()}/units/eks/addons/cilium/helm"
  path   = "eks/addons/cilium/helm"

  values = {
    version            = local.version
    helm_chart_version = local.version_cilium
    helm_values = {
      operator = {
        replicas = 2
      }
    }
  }
}
```

</TabItem>
<TabItem value="custom" label="Custom module">

Pass `local.version` as `version`, the catalog version the stack already resolves. For example, for the ACM certificate:
```hcl
unit "acm_certificate" {
  source = "${get_repo_root()}/units/eks/route53/acm_certificate"
  path   = "eks/route53/acm_certificate"

  values = {
    version = local.version
  }
}
```

</TabItem>
</Tabs>

Then add the unit's other `values`. If a value should only apply in `dev`, mark it with a `# DEV:` comment explaining why, so it isn't carried over to `staging` and `prod`:
```hcl
unit "loki_s3_chunks" {
  ...
  values = {
    version = local.version_s3
    # DEV: allows this dev stack to be destroyed without manually emptying the bucket first,
    # set to false for prod.
    force_destroy = true
  }
}
```

## Validate in Dev

Commit your changes and push your branch, replacing `<message>` and `<branch>`. Units fetch in-repo modules and bundled charts from git at your current branch, so local changes to them aren't picked up until they're pushed:
```bash
git add units/ modules/ charts/ pipelines/
git commit -m "<message>" # e.g. "feat: add loki s3 chunks bucket"
git push origin <branch>
```

Deploy the dev stack from the repository root. Clean it first, so no unit left over from a previous generate gets applied:
```bash
source .env
cd pipelines/dev/eks/stack
terragrunt stack clean
terragrunt stack generate
terragrunt run --all apply --backend-bootstrap --non-interactive --no-stack-generate
```

For an AWS resource, check that it exists with the AWS CLI or console. For example, for the Loki S3 chunks bucket:
```bash
aws s3 ls | grep dev-loki-chunks
```

For a Kubernetes add-on, check that its release is deployed and its pods are running. For example, for Cilium:
```bash
helm list -n kube-system
kubectl get pods -n kube-system -l app.kubernetes.io/part-of=cilium
```

Once it works, destroy the dev stack to stop paying for it:
```bash
terragrunt run --all destroy --non-interactive --no-stack-generate
```

## Commit the Lock File

If you added a unit or changed a provider version, commit its provider lock file, so a tag always resolves the same provider versions. CI fails on a unit without one.

The apply generated your unit's lock file under `.terragrunt-stack/`, which is wiped on every `stack clean`. From the repository root, copy it back into `units/`:
```bash
make sync-lock-files
```

This runs [`scripts/sync-lock-files.sh`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/scripts/sync-lock-files.sh), which copies each `.terragrunt-stack/<path>/.terraform.lock.hcl` to `units/<path>/.terraform.lock.hcl`.

Some units can't set `path` to their directory under `units/`, for example when a stack instantiates one unit several times. The script then reports them as failed:
```text
2 lock file(s) failed to sync:
  cp: .../units/ec2_spot_quota/.terraform.lock.hcl: No such file or directory
  cp: .../units/ec2_ondemand_quota/.terraform.lock.hcl: No such file or directory
```

If yours is one of them, copy its lock file into the unit's directory by hand, replacing `<stack-dir>` with the stack's directory, `<path>` with the unit's `path` in it, and `<unit-dir>` with the unit's directory under `units/`:
```bash
cp <stack-dir>/.terragrunt-stack/<path>/.terraform.lock.hcl units/<unit-dir>/
```

For example, the [`ec2_spot_quota`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/stacks/ec2_quotas/terragrunt.stack.hcl) unit is instantiated from [`units/service_quota`](https://github.com/ConsciousML/terragrunt-template-catalog-eks/tree/main/units/service_quota), inside the nested `ec2_quotas` stack:
```bash
cp pipelines/bootstrap/aws_service_quotas/.terragrunt-stack/ec2_quotas/.terragrunt-stack/ec2_spot_quota/.terraform.lock.hcl units/service_quota/
```

Check that the new lock file landed in your unit's directory, then commit it, replacing `<unit-dir>` with the unit's directory under `units/`:
```bash
git status units/
git add units/<unit-dir>/.terraform.lock.hcl # e.g. units/eks/addons/loki/s3/chunks/.terraform.lock.hcl
git commit -m "chore: pin provider lock files"
```

## Tag a Catalog Release

Push your branch and open a pull request, replacing `<branch>`, `<title>`, and `<description>` with what the unit deploys and how you validated it:
```bash
git push origin <branch>
gh pr create --title "<title>" --body "<description>"
```

Iterate until CI passes. If you wrote a module, CI generates its `README.md` and pushes it to your branch, so pull before pushing again:
```bash
git pull origin <branch>
```

Once it's merged, tag the merge commit on `main` and push the tag, replacing `<tag>` with the next version (e.g. `v0.2.0`). This is the ref `staging` and `prod` will pin to:
```bash
git checkout main
git pull origin main
git tag <tag>
git push origin <tag>
```

## Roll Out to Staging and Prod

To ship the unit to `staging` and `prod`, [bump the catalog version](/docs/iac/bump-the-catalog-version/) in your live repository to the new tag.
