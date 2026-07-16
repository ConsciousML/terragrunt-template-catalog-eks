# ArgoCD

Deploys ArgoCD into the cluster and wires up its admin password via AWS Secrets Manager and the External Secrets Operator, then bootstraps GitOps application delivery via the App of Apps pattern.

## Concepts

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [App of Apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [External Secret Operator (ESO)](https://external-secrets.io/latest/)
- [ESO SecretStore](https://external-secrets.io/latest/api/secretstore/)
- [ESO ExternalSecret](https://external-secrets.io/latest/api/externalsecret/)

## What's Inside

- **[aws_secret_password](aws_secret_password/)**: Generates a random admin password and stores it in AWS Secrets Manager
- **[helm](helm/)**: Deploys ArgoCD via Helm. Sets `global.domain` from `domains.hcl`
- **[app_of_apps](app_of_apps/)**: Deploys the root ArgoCD `Application` CR pointing to the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template)

The ESO `SecretStore` and `ExternalSecret` that sync the admin password's bcrypt hash into `argocd-secret` are deployed through app-of-apps (`argocd-secrets`, an instance of the generic [`helm-eso-secret-sync`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) chart), not Terraform. The ArgoCD server's `Ingress` and its gRPC `Service` are also deployed through app-of-apps, as [`helm-argocd-ingress`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-argocd-ingress), not by the `helm` unit above. See the [App of Apps integration guide](../../../../docs/app-of-apps-integration.md).

## Upstream Dependencies

- **[`units/eks/addons/prometheus_stack/crds`](../prometheus_stack/crds/)**: `helm` takes an ordering dependency on it so the Prometheus Operator CRDs exist before ArgoCD's own Helm release renders any `ServiceMonitor`
- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: `app_of_apps` takes an ordering dependency on its IAM role so the ESO controller can read the admin password secret once deployed through app-of-apps
- **[`units/eks/addons/aws_load_balancer_controller`](../aws_load_balancer_controller/)**: `app_of_apps` takes an ordering dependency on its IAM role so the Pod Identity association exists before ArgoCD deploys the controller
- **[`units/eks/addons/external_dns`](../external_dns/)**: `app_of_apps` takes an ordering dependency on both IAM roles so the Pod Identity associations exist before ArgoCD deploys either instance
- **[`units/eks/route53`](../../route53/)**: `helm` takes an ordering dependency on the private hosted zone. `app_of_apps` waits on both hosted zones so the ACM certificate exists before app-of-apps deploys `helm-argocd-ingress`, `gateway-public`, and `gateway-private`
- **[`units/eks/addons/karpenter`](../karpenter/)**: `app_of_apps` takes an ordering dependency on `iam` so the interruption queue and node IAM role exist before ArgoCD deploys the controller and node pool config
- **[`units/eks/addons/tailscale/oauth_client_secret`](../tailscale/oauth_client_secret/)**: `app_of_apps` takes an ordering dependency on it so the OAuth credentials exist before app-of-apps deploys `tailscale-secrets`
