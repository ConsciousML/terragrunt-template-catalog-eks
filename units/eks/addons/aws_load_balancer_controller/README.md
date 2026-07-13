# AWS Load Balancer Controller

Provisions the AWS-side IAM/Pod Identity resources for the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/), enabling Kubernetes `Ingress` and `Gateway` resources to provision ALBs on AWS.

The controller itself is **not deployed by this unit**. It is deployed through app-of-apps as [`helm-aws-lbc`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-aws-lbc).

## Concepts

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_policy_url](iam_policy_url/)**: Fetches the official IAM policy JSON from the upstream GitHub release URL for a version pinned in the dev stack. That pin must be kept in sync by hand with the `aws-load-balancer-controller` chart dependency version in app-of-apps's [`helm-aws-lbc/Chart.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/helm-aws-lbc/Chart.yaml). Nothing enforces this automatically
- **[iam_role](iam_role/)**: Creates an IAM role and binds it to the `aws-load-balancer-controller` service account in `kube-system` via EKS Pod Identity

## Integration

- **[`units/eks/addons/argocd/app_of_apps`](../argocd/app_of_apps/)**: takes an ordering dependency on `iam_role` so the Pod Identity association exists before ArgoCD deploys the controller
- **[`helm-aws-lbc`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-aws-lbc)** (app-of-apps): it's this chart that deploys the controller
