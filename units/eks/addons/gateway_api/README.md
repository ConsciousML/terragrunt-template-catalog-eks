# Gateway API

Provisions a shared, internet-facing ALB via the [AWS Load Balancer Controller Gateway API integration](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/gateway/l7gateway/).

## Concepts

- [Gateway API Overview](https://kubernetes.io/docs/concepts/services-networking/gateway/)
- [Resource model](https://kubernetes.io/docs/concepts/services-networking/gateway/#resource-model): role of `GatewayClass`, `Gateway`, and `HTTPRoute`

## What's Inside

- **[kubectl_manifest_from_url](../kubectl_manifest_from_url/)**: Installs the standard Gateway API CRDs and the AWS LBC gateway CRDs (pipelines/dev/eks/terragrunt.stack.hcl)
- **[namespace](namespace/)**: Creates the `gateway` Kubernetes namespace
- **[gateway_class](gateway_class/)**: Registers `aws-alb` as the GatewayClass bound to `gateway.k8s.aws/alb`
- **[load_balancer_configuration/public](load_balancer_configuration/public/)**: Configures the ALB as `internet-facing` and attaches the ACM certificate to `HTTPS:443`. TLS termination is declared here, not in the Gateway listener spec
- **[gateway/public](gateway/public/)**: Declares `HTTP:80` (named `http`) and `HTTPS:443` (named `https`) listeners. Its `name` and `namespace` outputs flow into [`argocd/app_of_apps`](../argocd/app_of_apps/)

## Integration

- **[AWS Load Balancer Controller](../aws_load_balancer_controller/)**: provisions the ALB and implements the `aws-alb` GatewayClass controller
- **ACM**: `load_balancer_configuration/public` references the guestbook ACM certificate for TLS termination on `HTTPS:443`
- **[ExternalDNS](../external_dns/)**: watches `HTTPRoute` resources attached to this Gateway and creates Route53 records for matching hostnames
- **[App of Apps](../argocd/app_of_apps/)**: `gateway/public` outputs are passed as Helm values to each child app, allowing them to reference the Gateway in their `HTTPRoute`
- **Apps**: each app creates an `HTTPRoute` bound to this Gateway. See [`guestbook-httproute.yaml`](https://github.com/ConsciousML/argocd-app-of-apps-template/blob/main/guestbook-helm/templates/guestbook-httproute.yaml) as a reference
