# ExternalDNS

Provisions the AWS-side IAM/Pod Identity resources for two [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/) instances, one scoped to the private hosted zone and one to the public hosted zone. Both instances are deployed with app-of-apps, not by this unit.

## Concepts

- [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[private/iam_role](private/iam_role/)**: Creates an IAM role bound to the `external-dns-private` service account via Pod Identity, with Route53 write access scoped to the private hosted zone
- **[public/iam_role](public/iam_role/)**: Creates an IAM role bound to the `external-dns-public` service account via Pod Identity, with Route53 write access scoped to the public hosted zone

## Integration

- **[`units/eks/addons/argocd/app_of_apps`](../argocd/app_of_apps/)**: takes an ordering dependency on each `iam_role` so the Pod Identity association exists before ArgoCD deploys the instance
- **[`helm-external-dns-private`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-external-dns-private)** and **[`helm-external-dns-public`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-external-dns-public)** (app-of-apps): these are the charts that deploy each instance
- **[`units/eks/route53`](../../route53/)**: each instance reads its hosted zone domain name as a domain filter via `app_of_apps`'s dependency on the zone
