# Karpenter

Provisions the AWS resources required to run [Karpenter](https://karpenter.sh/) as the node autoscaler for the EKS cluster.

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

- **[iam](iam/)**: Creates the controller IAM role (bound to the `karpenter` service account in `kube-system` via Pod Identity), the node IAM role with its access entry so Karpenter-provisioned nodes can join the cluster, and the SQS queue with EventBridge rules for spot interruption and capacity rebalancing. Its `queue_name` and `node_iam_role_name` outputs flow into `helm` and `ec2_node_class` respectively
- **[helm](helm/)**: Deploys the Karpenter controller via Helm from the OCI registry (`public.ecr.aws/karpenter/karpenter`). Wires `settings.clusterName` and `settings.interruptionQueue` from dependencies. Exposes `settings.enableZonalShift` and controller resource requests/limits as stack-level values
- **[ec2_node_class](ec2_node_class/)**: Creates the `EC2NodeClass` CRD that defines the node configuration: IAM role for nodes, AMI selector, and subnet/security group discovery via the `karpenter.sh/discovery` tag. Outputs the resource `name` so `node_pool` can reference it as a dependency
- **[node_pool](node_pool/)**: Creates the `NodePool` CRD that defines scheduling constraints (instance family, arch, capacity type), cost limits, and disruption policy. Takes a dependency on `ec2_node_class` and merges `nodeClassRef` from its output name, keeping the rest of the spec stack-controlled

## Integration

- **[`units/eks/cluster`](../../cluster/)**: `iam` takes a dependency on the cluster for its name and to register the node role access entry; `helm` and `ec2_node_class` use the cluster name for controller settings and discovery tag matching
- **[`units/eks/vpc`](../../vpc/)**: Subnets must carry the `karpenter.sh/discovery = <cluster-name>` tag (set via `private_subnet_tags` in the stack) so Karpenter can discover them when provisioning nodes
