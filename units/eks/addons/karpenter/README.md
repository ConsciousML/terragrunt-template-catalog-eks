# Karpenter

Provisions the AWS resources required to run [Karpenter](https://karpenter.sh/) as the node autoscaler for the EKS cluster.

## Concepts

- [Karpenter](https://karpenter.sh/docs/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam](iam/)**: Creates the controller IAM role (bound to the `karpenter` service account in `kube-system` via Pod Identity), the node IAM role with its access entry so Karpenter-provisioned nodes can join the cluster, and the SQS queue with EventBridge rules for spot interruption and capacity rebalancing. Its `queue_name` output flows into `helm`
- **[helm](helm/)**: Deploys the Karpenter controller via Helm from the OCI registry (`public.ecr.aws/karpenter/karpenter`). Wires `settings.clusterName` and `settings.interruptionQueue` from dependencies. Exposes `settings.enableZonalShift` and controller resource requests/limits as stack-level values

## Integration

- **[`units/eks/cluster`](../../cluster/)**: `iam` takes a dependency on the cluster for its name and to register the node role access entry; `helm` uses the cluster name for `settings.clusterName`
