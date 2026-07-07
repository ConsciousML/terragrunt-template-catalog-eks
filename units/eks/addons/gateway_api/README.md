# Gateway API

Provisions shared internet-facing and internal ALBs via the [AWS Load Balancer Controller Gateway API integration](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/l7gateway/). The units in this group are split by role so platform-level defaults (target type, TLS) are owned here and app-level routing is owned by each app's `HTTPRoute`.

## Concepts

- [Gateway API Overview](https://kubernetes.io/docs/concepts/services-networking/gateway/)
- [Resource model](https://kubernetes.io/docs/concepts/services-networking/gateway/#resource-model): role of `GatewayClass`, `Gateway`, and `HTTPRoute`

## What's Inside

- **[namespace](namespace/)**: Creates the `gateway` Kubernetes namespace
- **[gateway_class](gateway_class/)**: Registers `aws-alb` as the GatewayClass bound to `gateway.k8s.aws/alb`
- **[target_group_configuration/public](target_group_configuration/public/)**: Sets `ip` as the default target type so backends are reached via pod IP, without requiring `NodePort` on backend services
- **[load_balancer_configuration/public](load_balancer_configuration/public/)**: Configures the ALB as `internet-facing` and attaches the ACM certificate to `HTTPS:443`. TLS termination is declared here, not in the Gateway listener spec
- **[gateway/public](gateway/public/)**: Declares `HTTP:80` and `HTTPS:443` listeners. Its `name` and `namespace` outputs flow into [`argocd/app_of_apps`](../argocd/app_of_apps/)
- **[target_group_configuration/private](target_group_configuration/private/)**: Same as the public unit, `ip` target type for backends reached via internal-only routes
- **[load_balancer_configuration/private](load_balancer_configuration/private/)**: Configures the ALB as `internal` and attaches the same shared ACM certificate to `HTTPS:443`
- **[gateway/private](gateway/private/)**: Declares `HTTP:80` and `HTTPS:443` listeners on the internal ALB, sharing the same `aws-alb` GatewayClass as `gateway/public`

## Integration

- **[AWS Load Balancer Controller](../aws_load_balancer_controller/)**: provisions the ALB and implements the `aws-alb` GatewayClass controller
- **ACM**: `load_balancer_configuration/public` and `load_balancer_configuration/private` both reference the shared wildcard ACM certificate for TLS termination on `HTTPS:443`
- **[ExternalDNS](../external_dns/)**: watches `HTTPRoute` resources attached to this Gateway and creates Route53 records for matching hostnames
- **[App of Apps](../argocd/app_of_apps/)**: `gateway/public` outputs are passed as Helm values to each child app, allowing them to reference the Gateway in their `HTTPRoute`
- **Apps**: each app creates an `HTTPRoute` bound to this Gateway. See [`guestbook-httproute.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/guestbook-helm/templates/guestbook-httproute.yaml) as a reference
