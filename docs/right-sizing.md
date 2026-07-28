# Right-Sizing

Guide to right-sizing a workload's CPU and memory requests using the VPA recommender and Goldilocks.

The Helm releases are configured in the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template)'s [`helm-vpa/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-vpa/values.yaml) and [`helm-goldilocks/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-goldilocks/values.yaml). Implementation details below link there.

## Prerequisites

- All [bootstrap pipelines](../pipelines/bootstrap/README.md) have been run
- The [Tailscale client](../pipelines/bootstrap/tailscale/README.md#prerequisites) is installed and connected (the dashboard is private)
- The [EKS stack](../units/eks/README.md) is deployed, in any environment (`dev`, `staging`, `prod`)

URLs below use `<environment>` and `<base_domain>` as placeholders, e.g. `goldilocks.private.dev.axelmendoza.com` for the `dev` environment with `base_domain = axelmendoza.com` (see [`pipelines/dns.hcl`](../pipelines/dns.hcl)).

## What's Deployed

- **[Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) (recommender only)**: watches every workload's usage history and writes a request recommendation to each `VerticalPodAutoscaler`'s status. The `updater` and `admissionController` are disabled, so nothing here evicts or resizes a running pod
- **[Goldilocks](https://goldilocks.docs.fairwinds.com/)**: creates a `VerticalPodAutoscaler` for every workload controller in every namespace and summarizes its recommendation in a dashboard
- **EKS `metrics-server` addon**: live CPU and memory usage the VPA recommender reads from, managed as a cluster addon in [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](../pipelines/dev/eks/stack/terragrunt.stack.hcl), not by either Helm release above

## Let the Workload Run Under Load

Every workload controller gets a `VerticalPodAutoscaler` automatically (see [Adding a New Workload](#adding-a-new-workload)), and the recommender starts building a usage histogram from the moment the workload exists. Don't read a recommendation right after deploying a workload, it's built from too little history to mean anything.

Give it a reasonable amount of time before trusting the numbers, long enough to span the workload's peak and off-peak usage.

## Read the Recommendation

Open `https://goldilocks.private.<environment>.<base_domain>`. It lists every namespace and workload, each with a lower bound, a target, and an upper bound for CPU and memory.

Use the **target** column as your new request. It already has the percentile and safety margin tuning described in [Tuning the Recommendation Strategy](#tuning-the-recommendation-strategy) baked in, no further adjustment needed for typical workloads.

## Apply the Recommendation

Goldilocks and the recommender only compute and display numbers. Nothing in this stack writes them back into a workload's [`resources`](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) block, so update it by hand:

- For a Terraform-managed workload, edit its `resources` in this repo (`units/` or the module's `values`) and re-apply
- For a Helm-deployed workload, edit its `resources` in the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template) and let ArgoCD sync it

Set the request to the target. For CPU, set the limit to 2 to 5 times the request, so the workload can burst without throttling. For memory, set the limit to the target itself, since headroom above it only delays an OOM kill instead of preventing one.

## Verify

After the change rolls out, watch the workload in [Grafana](monitoring.md) for CPU throttling or OOM kills over the next traffic cycle. Then check the Goldilocks dashboard again, the target should now sit close to the new request instead of pointing further away from it.

## Tuning the Recommendation Strategy

The recommender exposes two independent controls per resource:

- **Percentile target**: how far into the usage distribution the recommendation reaches, set per resource via `recommender.extraArgs` in [`helm-vpa/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-vpa/values.yaml)
- **Safety margin**: a percentage added on top of the percentile target, applied uniformly to both CPU and memory (upstream VPA has no per-resource margin flag), set via `recommendation-margin-fraction` in the same file

Memory is tuned to a higher percentile than CPU. An undersized memory request ends in an OOM kill, a hard failure, so memory recommendations stack a higher percentile on top of the safety margin. An undersized CPU request only causes throttling, a soft, recoverable failure, so CPU is left at the chart's default percentile rather than stacking a second hedge on top of the same margin.

## Adding a New Workload

Goldilocks runs in `on-by-default` mode (`controller.flags.on-by-default` in [`helm-goldilocks/values.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-goldilocks/values.yaml)), so a new workload controller gets a `VerticalPodAutoscaler` and shows up on the dashboard without any per-namespace labeling.
