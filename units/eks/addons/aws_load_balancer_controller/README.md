# AWS Load Balancer Controller

Deploys the [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/) into the cluster, enabling Kubernetes `Ingress` and `Gateway` resources to provision ALBs on AWS.

## Concepts

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[iam_policy_url](iam_policy_url/)**: Fetches the official IAM policy JSON from the upstream GitHub release URL, ensuring the policy stays in sync with the Helm chart version. Its `body` output flows into `iam_role`
- **[iam_role](iam_role/)**: Creates an IAM role and binds it to the `aws-load-balancer-controller` service account in `kube-system` via EKS Pod Identity. Its `namespace` output flows into `helm`
- **[helm](helm/)**: Deploys the controller via Helm. Waits on `iam_role`, `gateway_api_crds`, and the ACM certificate before deploying

## Integration

- **[`units/vpc`](../../../vpc/)**: `helm` passes the VPC ID to the controller so it can discover subnets when provisioning ALBs
- **[`units/eks/addons/gateway_api`](../gateway_api/)**: `helm` waits for the Gateway API CRDs to be installed before deploying, as the controller registers itself as the `aws-alb` GatewayClass controller
- **[`units/eks/route53/acm_certificate`](../../route53/acm_certificate/)**: `helm` takes an ordering dependency on the ACM certificate so TLS is ready before the controller starts reconciling ingress resources
