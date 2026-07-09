# Karpenter

Provisions the AWS-side IAM/Pod Identity resources required to run [Karpenter](https://karpenter.sh/) as the node autoscaler for the EKS cluster.

The controller and its node configuration are **not deployed by this unit**. They are deployed through app-of-apps as [`helm-karpenter`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-karpenter) (the controller) and [`helm-karpenter-config`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-karpenter-config) (`EC2NodeClass` and `NodePool`).

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

- **[iam](iam/)**: Creates the controller IAM role (bound to the `karpenter` service account in `kube-system` via Pod Identity), the node IAM role with its access entry so Karpenter-provisioned nodes can join the cluster, and the SQS queue with EventBridge rules for spot interruption and capacity rebalancing. Its `queue_name` and `node_iam_role_name` outputs flow into app-of-apps as Helm values for `helm-karpenter` and `helm-karpenter-config` respectively

## Integration

- **[`units/eks/cluster`](../../cluster/)**: `iam` takes a dependency on the cluster for its name and to register the node role access entry
- **[`units/eks/vpc`](../../vpc/)**: Subnets must carry the `karpenter.sh/discovery = <cluster-name>` tag (set via `private_subnet_tags` in the stack) so Karpenter can discover them when provisioning nodes
- **[`units/eks/addons/argocd/app_of_apps`](../argocd/app_of_apps/)**: deploys the controller and node configuration through app-of-apps as [`helm-karpenter`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-karpenter) and [`helm-karpenter-config`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-karpenter-config). Takes an ordering dependency on `iam` and passes `queue_name` and `node_iam_role_name` through as Helm values
