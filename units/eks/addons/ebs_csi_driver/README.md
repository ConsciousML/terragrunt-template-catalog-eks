# EBS CSI Driver

Installs the [Amazon EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) as an EKS managed addon, enabling `PersistentVolumeClaim` provisioning backed by EBS volumes.

## Concepts

- [Amazon EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `ebs-csi-controller-sa` service account in `kube-system` via Pod Identity, with the AWS-managed EBS CSI driver policy attached
- **[addon](addon/)**: Installs the `aws-ebs-csi-driver` EKS managed addon, depending on both `units/eks/cluster` and `iam_role` so the Pod Identity association exists before the addon is installed
- **[`storage-class-gp3`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/manifests/storage-class-gp3)** (app-of-apps): the default `gp3` `StorageClass`. Not deployed by this unit

This unit only installs the driver. It creates no `StorageClass`. Without `storage-class-gp3` synced too, every `PersistentVolumeClaim` stays `Pending`.

## Upstream Dependencies

- **[`units/eks/cluster`](../../cluster/)**: Provides the `cluster_name` output consumed by both `iam_role` and `addon`. Without the `addon` unit waiting on `iam_role`, the controller pod starts without credentials and the addon stays in `CREATING` indefinitely
