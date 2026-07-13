# External Secrets Operator

Provisions the AWS-side IAM/Pod Identity resources for the [External Secrets Operator](https://external-secrets.io/latest/), which syncs secrets from AWS Secrets Manager into Kubernetes `Secret` objects.

The operator itself is **not deployed by this unit**. It is deployed through app-of-apps as [`helm-external-secrets-operator`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-external-secrets-operator).

## Concepts

- [External Secrets Operator](https://external-secrets.io/latest/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `external-secrets` service account via Pod Identity. Read access is scoped to secrets prefixed with `{environment}-`

## Integration

- **[`units/eks/addons/argocd`](../argocd/)**: `aws_secret_password` stores the admin password ESO later syncs in via its own app-of-apps-managed `SecretStore` and `ExternalSecret`.
- **[`helm-external-secrets-operator`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-external-secrets-operator)** (app-of-apps): it's this chart that deploys the operator
