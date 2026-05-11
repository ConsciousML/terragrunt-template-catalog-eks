# AWS External Secret Store

Creates a namespaced ESO [`SecretStore`](https://external-secrets.io/latest/api/secretstore/) backed by AWS Secrets Manager. Authentication is handled transparently via EKS Pod Identity — no static credentials required.
