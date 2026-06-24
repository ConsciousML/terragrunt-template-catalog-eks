# Dev EKS Stack

Local development instantiation of the [EKS Cluster Stack](../../../units/eks/README.md). Use this environment to iterate on catalog changes before promoting them to `staging` and `prod` in the [live repository](https://github.com/ConsciousML/terragrunt-template-live-eks).

## Dev-specific configuration

- Module sources use `get_repo_root()` to point at the local catalog rather than a pinned git ref, so changes are picked up immediately without pushing a tag
- ArgoCD password secret has `recovery_window_in_days = 0` for fast teardown during local iteration
- Node groups use `t3.medium` instances to minimize cost
