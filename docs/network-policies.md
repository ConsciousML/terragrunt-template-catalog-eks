# Network Policies

How to secure the internal cluster network: build a feature in a namespace unrestricted, confirm it works, then lock its traffic down to exactly what it needs.

## Prerequisites

- All [bootstrap pipelines](../pipelines/bootstrap/README.md) have been run
- [Tailscale](../pipelines/bootstrap/tailscale/README.md#prerequisites) is connected (Hubble UI is private)
- The [EKS stack](../units/eks/README.md) is deployed
- Read Cilium's [policy overview](https://docs.cilium.io/en/stable/security/policy/), [layer 3](https://docs.cilium.io/en/stable/security/policy/layer3/), and [layer 4](https://docs.cilium.io/en/stable/security/policy/layer4) docs

## Concepts

[Cilium](https://cilium.io/) is the sole `NetworkPolicy` enforcer, in [CNI chaining mode](https://docs.cilium.io/en/stable/installation/cni-chaining/) alongside `vpc-cni`. Configured in the [App of Apps repo](https://github.com/ConsciousML/argocd-app-of-apps-template)'s [`charts/cilium/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/cilium/values.yaml). See [Monitoring](monitoring.md#network-observability-hubble) for how Hubble is deployed and its UI.

## How Enforcement Works

A namespace is unrestricted until opted into default-deny, nothing default-denies the whole cluster at once.

There are two policy kinds:

- **`CiliumClusterwideNetworkPolicy`**: see [`manifests/network-policies/cluster-wide/README.md`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/manifests/network-policies/cluster-wide/README.md)
- **`CiliumNetworkPolicy`**: one per workload, colocated with it, either a flat manifest ([`manifests/podinfo/podinfo-network-policy.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/manifests/podinfo/podinfo-network-policy.yaml)) or a `templates/network-policy.yaml` in a chart wrapping an upstream dependency ([`charts/right-sizing/vpa`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/right-sizing/vpa/templates/network-policy.yaml), [`charts/right-sizing/goldilocks`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/charts/right-sizing/goldilocks/templates/network-policy.yaml))

## Adding a Feature to a Namespace

**Build it unrestricted.** If `<namespace>` is already in [`default-deny.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/manifests/network-policies/cluster-wide/default-deny.yaml)'s `values` list, drop it out for now (skip if `<namespace>` is new, it isn't in there yet). Implement and deploy the feature, and confirm it works end to end. 

Capture what network communication it needs. Watch its real traffic using `hubble`:

```bash
hubble observe -n <namespace> -P
```

Cross-check against the workload's spec: ports, probes, whether it's reached via a Gateway API `HTTPRoute` (arrives as `world`, see [Identities in This Cluster](#identities-in-this-cluster)), what it calls out to.

**Write the rules.** A concern shared by several namespaces (API server, DNS) goes in an existing cluster-wide file, see [`manifests/network-policies/cluster-wide/README.md`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/manifests/network-policies/cluster-wide/README.md). A concern specific to this workload goes in its own `CiliumNetworkPolicy`, see [Writing a Workload Policy](#writing-a-workload-policy).

**Turn deny-on.** Add `<namespace>` back to `default-deny.yaml`, commit, push, `argocd app sync`, restart the workload.

**Re-verify.** `hubble observe -n <namespace> --verdict DROPPED -P` should now return anything, and the feature should still work end to end, see [Verify](#verify). Iterate the capture and write steps for anything still broken.

## Writing a Workload Policy

Scope `endpointSelector` to the component-level labels a chart's pods carry (`app.kubernetes.io/component`, not just `name`), so a multi-deployment chart gets independently scoped rules.

Only add an `ingress` or `egress` block for a direction the workload needs. The namespace's actual default-deny comes from `default-deny.yaml` (policies on one endpoint combine, default-deny wins if any requests it), so a workload policy only needs to add allows on top.

Comment each rule with why the flow exists, not what the YAML says. See `charts/right-sizing/vpa/templates/network-policy.yaml` and `manifests/podinfo/podinfo-network-policy.yaml` for the shape.

## Verify

`hubble observe -n <namespace> --verdict DROPPED -P` stays clean (no `Policy denied`, only IPv6 noise) across a normal traffic cycle, not just the first few seconds after restart. The feature itself still works end to end, a clean Hubble window only proves the network layer.
