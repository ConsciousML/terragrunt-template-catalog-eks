# ExternalDNS

Deploys two separate [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/) instances into the cluster, one scoped to the private hosted zone and one to the public hosted zone. Each instance watches `HTTPRoute` and `Ingress` resources and creates DNS records only in its assigned zone.

## Concepts

- [ExternalDNS](https://kubernetes-sigs.github.io/external-dns/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)

## What's Inside

- **[private/iam_role](private/iam_role/)**: Creates an IAM role bound to the `external-dns-private` service account via Pod Identity, with Route53 write access scoped to the private hosted zone
- **[private/helm](private/helm/)**: Deploys the `external-dns-private` instance filtered to the private hosted zone domain. Records created here are only reachable over the Tailnet
- **[public/iam_role](public/iam_role/)**: Creates an IAM role bound to the `external-dns-public` service account via Pod Identity, with Route53 write access scoped to the public hosted zone
- **[public/helm](public/helm/)**: Deploys the `external-dns-public` instance filtered to the public hosted zone domain. Records created here are publicly resolvable

Both `helm` units set a `txtPrefix` using the record type (e.g. `a-external-dns-private-{cluster}.`) so TXT ownership records don't conflict with the records they track. They also run a 60-second sleep before destroy to let ExternalDNS clean up DNS records before the hosted zones are torn down.

## Integration

- **[`units/eks/route53`](../../route53/)**: each instance reads its hosted zone domain name as a domain filter and takes an ordering dependency on the zone
- **[`units/eks/addons/gateway_api`](../gateway_api/)**: both instances wait on the Gateway API CRDs since they watch `HTTPRoute` resources
- **[`units/eks/addons/aws_load_balancer_controller`](../aws_load_balancer_controller/)**: both instances wait on the controller to be ready before deploying
