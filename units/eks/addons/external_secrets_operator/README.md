# External Secrets Operator

Deploys the [External Secrets Operator](https://external-secrets.io/latest/) into the cluster, syncing secrets from AWS Secrets Manager into Kubernetes `Secret` objects.

## Concepts

- [External Secrets Operator](https://external-secrets.io/latest/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `external-secrets` service account via Pod Identity. Read access is scoped to secrets prefixed with `{environment}-` only

The operator itself is deployed through app-of-apps ([`helm-external-secrets-operator`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-external-secrets-operator)), not Terraform.

## Integration

- **[`units/eks/addons/argocd`](../argocd/)**: `aws_secret_password` stores the admin password ESO later syncs in via its own app-of-apps-managed `SecretStore`/`ExternalSecret`
