# External Secrets Operator

Deploys the [External Secrets Operator](https://external-secrets.io/latest/) into the cluster, syncing secrets from AWS Secrets Manager into Kubernetes `Secret` objects.

## Concepts

- [External Secrets Operator](https://external-secrets.io/latest/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `external-secrets` service account via Pod Identity. Read access is scoped to secrets prefixed with `{environment}-` only
- **[helm](helm/)**: Deploys the operator via Helm using the namespace from `iam_role`

## Integration

- **[`units/eks/addons/argocd`](../argocd/)**: `aws_password_secret`, `aws_secret_store`, and `aws_external_secret` all depend on ESO being deployed before creating their resources
