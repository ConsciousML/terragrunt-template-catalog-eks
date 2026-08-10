# External Secrets Operator

Provisions the AWS-side IAM/Pod Identity resources for the [External Secrets Operator](https://external-secrets.io/latest/), which syncs secrets from AWS Secrets Manager into Kubernetes `Secret` objects.

## Concepts

- [External Secrets Operator](https://external-secrets.io/latest/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_role](iam_role/)**: Creates an IAM role bound to the `external-secrets` service account via Pod Identity. Read access is scoped to secrets prefixed with `{environment}-`
- **[`external-secrets-operator`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/charts/external-secrets-operator/operator)** (app-of-apps): deploys the operator itself, using the Pod Identity association `iam_role` creates. Not deployed by this unit
