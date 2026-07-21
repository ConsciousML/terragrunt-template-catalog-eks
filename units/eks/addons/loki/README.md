# Loki

Provisions the AWS-side S3 and Pod Identity resources for [Loki](https://grafana.com/docs/loki/latest/), used for cluster-wide log aggregation.

## Concepts

- [Loki](https://grafana.com/docs/loki/latest/)
- [Loki Storage](https://grafana.com/docs/loki/latest/storage/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[s3/chunks](s3/chunks/)**: S3 bucket storing Loki's log chunks
- **[s3/ruler](s3/ruler/)**: S3 bucket storing Loki's ruler (alerting/recording rule) state
- **[iam_role](iam_role/)**: Creates an IAM role bound to the `loki` service account via Pod Identity. Read and write access is scoped to the two buckets above
- **[`helm-loki`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-loki)** (app-of-apps): deploys Loki itself, using the Pod Identity association `iam_role` creates. Not deployed by this unit
