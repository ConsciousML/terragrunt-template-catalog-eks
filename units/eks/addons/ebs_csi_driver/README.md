# EBS CSI Driver

Installs the [Amazon EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) as an EKS managed addon, enabling `PersistentVolumeClaim` provisioning backed by EBS volumes.

## Concepts

- [Amazon EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `ebs-csi-controller-sa` service account in `kube-system` via Pod Identity, with the AWS-managed `AmazonEBSCSIDriverPolicyV2` policy attached. Reads the cluster name from config rather than from the cluster dependency so it can run before the cluster unit and guarantee the Pod Identity association exists before the addon is installed

## Integration

- **[`units/eks/cluster`](../../cluster/)**: Declares a dependency on `iam_role` so the Pod Identity association is in place before the `aws-ebs-csi-driver` addon is installed. Without this ordering the controller pod starts without credentials and the addon stays in `CREATING` indefinitely
