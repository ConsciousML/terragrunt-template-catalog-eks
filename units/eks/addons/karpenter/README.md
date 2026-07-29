# Karpenter

Runs [Karpenter](https://karpenter.sh/) as the node autoscaler for the EKS cluster: the controller, its AWS-side IAM/Pod Identity resources, the shared `EC2NodeClass`, and the critical `NodePool`. The elastic `NodePool` is deployed separately, via app-of-apps.

> **Note**: The critical `NodePool` caps total vCPUs via `spec.limits.cpu` in [node_pool/critical](node_pool/critical/), and the elastic one does the same in [`helm-karpenter-node-pool/templates/node-pool.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-karpenter-node-pool/templates/node-pool.yaml) in the App of Apps repository. Raise either limit if that pool needs more headroom.

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
- **[`helm-karpenter-config`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-karpenter-config)** (app-of-apps): deploys the `EC2NodeClass` and `NodePool`. Not deployed by this unit

## Upstream Dependencies

- **[`units/eks/cluster`](../../cluster/)**: `iam` takes a dependency on the cluster for its name and to register the node role access entry
- **[`units/vpc`](../../../vpc/)**: Subnets must carry the `karpenter.sh/discovery = <cluster-name>` tag (set via `private_subnet_tags` in the stack) so Karpenter can discover them when provisioning nodes
