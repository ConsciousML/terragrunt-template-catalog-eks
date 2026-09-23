# Cilium

Runs [Cilium](https://cilium.io/) in [CNI chaining mode](https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/) alongside `vpc-cni`, as the cluster's sole `NetworkPolicy` enforcer and for [Hubble](https://docs.cilium.io/en/stable/observability/hubble/) network flow visibility. Values are set in [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](../../../../pipelines/dev/eks/stack/terragrunt.stack.hcl).

Cilium only manages pods created once `cilium-agent` is ready on their node. A pod started earlier gets an IP from `vpc-cni` but no `CiliumEndpoint`, and every policy then sees it as `world`. Two things close that gap:

- **New Karpenter nodes**: both NodePools carry the `node.cilium.io/agent-not-ready` [startup taint](https://docs.cilium.io/en/latest/installation/taints/), so pods wait until `cilium-agent` is ready there. `cilium-operator` removes it
- **Pods created with the cluster** (coredns, metrics-server): started before Cilium existed, restarted once by [cep_restart](cep_restart/)

Everything Cilium needs runs on the MNG, installed before Karpenter: `cilium-operator` must never depend on a Karpenter node to remove the taint that Karpenter nodes wait on. Hubble Relay and UI run there too, so flows stay visible when Karpenter nodes are the ones misbehaving.

## Concepts

- [CNI chaining with AWS VPC CNI](https://docs.cilium.io/en/stable/installation/cni-chaining-aws-cni/)
- [Cilium node taints](https://docs.cilium.io/en/latest/installation/taints/)
- [Karpenter startup taints](https://karpenter.sh/docs/concepts/nodepools/)
- [Helm chart hooks](https://helm.sh/docs/topics/charts_hooks/)

## What's Inside

- **[helm](helm/)**: Deploys Cilium via the upstream `cilium` chart. The API server host is injected from the cluster endpoint, since the agent can't use `kubernetes.default.svc` before its own service load-balancing is up
- **[cep_restart](cep_restart/)**: Deploys a Helm `post-install`/`post-upgrade` hook `Job`, via a chart bundled locally under [`charts/cilium-cep-restart`](../../../../charts/cilium-cep-restart/), that restarts every workload with a pod missing a `CiliumEndpoint`. Helm blocks on the hook, so the apply only moves on to Karpenter once it's done. It reruns on every Cilium version bump

## Querying Hubble Metrics

See the [Hubble metrics reference](https://docs.cilium.io/en/stable/observability/metrics/#hubble) for the full metric catalog, labels, and context options. Prometheus names are `hubble_` plus the reference's `Name` column (e.g. `flows_processed_total` is queried as `hubble_flows_processed_total`). The reference tables don't spell out the prefix.

## Upstream Dependencies

- **[`units/eks/cluster`](../../cluster/)**: `helm` reads the cluster endpoint for `k8sServiceHost`
- **[`units/eks/addons/prometheus_stack/crds`](../prometheus_stack/crds/)**: `helm` depends on it so the Prometheus Operator CRDs exist before the chart renders its `ServiceMonitor`s
- **[helm](helm/)**: `cep_restart` depends on it, the hook `Job` needs `cilium-agent` running and the `CiliumEndpoint` CRD installed
