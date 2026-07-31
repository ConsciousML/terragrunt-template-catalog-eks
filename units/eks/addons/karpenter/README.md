# Karpenter

Runs [Karpenter](https://karpenter.sh/) as the node autoscaler for the EKS cluster: the controller, its AWS-side IAM/Pod Identity resources, the shared `EC2NodeClass`, and NodePools.

Two NodePools split workloads by how disruption-sensitive they are. The critical pool takes a `workload-class=critical` taint with a conservative disruption policy, for workloads that shouldn't be evicted just because a node looks underutilized. The elastic pool consolidates more aggressively, for everything else. A workload opts into a pool with a matching `nodeSelector` and toleration.

> **Note**: Each NodePool's vCPU limit and capacity-type requirement are set in [`pipelines/dev/eks/stack/terragrunt.stack.hcl`](../../../../pipelines/dev/eks/stack/terragrunt.stack.hcl). Raise a limit if a pool needs more headroom, and switch the critical NodePool's capacity-type to on-demand for prod.

## Prerequisites

The EC2 Spot service-linked role must exist in your AWS account before Karpenter can provision spot instances. Create it once per account:

```bash
aws iam create-service-linked-role --aws-service-name spot.amazonaws.com || true
```

## Concepts

- [Karpenter](https://karpenter.sh/docs/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
- [NodePool](https://karpenter.sh/docs/concepts/nodepools/)
- [EC2NodeClass](https://karpenter.sh/docs/concepts/nodeclasses/)

## What's Inside

- **[iam](iam/)**: Creates the controller IAM role (bound to the `karpenter` service account in `kube-system` via Pod Identity), the node IAM role with its access entry so Karpenter-provisioned nodes can join the cluster, and the SQS queue with EventBridge rules for spot interruption and capacity rebalancing
- **[helm](helm/)**: Deploys the Karpenter controller itself via the upstream `karpenter` chart
- **[ec2_node_class](ec2_node_class/)**: Deploys the `EC2NodeClass` both NodePools reference, via a chart bundled locally under [`charts/karpenter-ec2-node-class`](../../../../charts/karpenter-ec2-node-class/)
- **[node_pool/critical](node_pool/critical/)**: Deploys the critical `NodePool`, via a chart bundled locally under [`charts/karpenter-node-pool`](../../../../charts/karpenter-node-pool/)
- **[node_pool/elastic](node_pool/elastic/)**: Deploys the elastic `NodePool`, via the same bundled chart as the critical one

## Upstream Dependencies

- **[`units/eks/cluster`](../../cluster/)**: `iam` depends on it for the cluster name and to register the node role access entry
- **[`units/eks/addons/prometheus_stack/crds`](../prometheus_stack/crds/)**: `helm` depends on it so the Prometheus Operator CRDs exist before Karpenter's own Helm release renders any `ServiceMonitor`
- **[`units/vpc`](../../../vpc/)**: `ec2_node_class` requires subnets to carry the `karpenter.sh/discovery = <cluster-name>` tag (set via `private_subnet_tags` in the stack) so Karpenter can discover them when provisioning nodes
