# ArgoCD

Deploys ArgoCD into the cluster and wires up its admin password via AWS Secrets Manager and the External Secrets Operator, then bootstraps GitOps application delivery via the App of Apps pattern.

## Concepts

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [App of Apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [External Secret Operator (ESO)](https://external-secrets.io/latest/)
- [ESO SecretStore](https://external-secrets.io/latest/api/secretstore/)
- [ESO ExternalSecret](https://external-secrets.io/latest/api/externalsecret/)

## What's Inside

- **[aws_password_secret](aws_password_secret/)**: Generates a random admin password and stores it in AWS Secrets Manager. Its `secret_name` output flows into `aws_external_secret`
- **[aws_secret_store](aws_secret_store/)**: Creates an ESO `SecretStore` in the `argocd` namespace backed by AWS Secrets Manager. Its `name` and `namespace` outputs flow into `aws_external_secret`
- **[aws_external_secret](aws_external_secret/)**: Creates an ESO `ExternalSecret` that syncs the bcrypt hash of the admin password from Secrets Manager into the `argocd-secret` Kubernetes secret. ArgoCD reads this secret on startup to set the admin password
- **[helm](helm/)**: Deploys ArgoCD via Helm. Sets `global.domain` from `domains.hcl` and attaches the ACM certificate ARN to the ALB ingress annotation for TLS termination on HTTPS
- **[app_of_apps](app_of_apps/)**: Deploys the root ArgoCD `Application` CR pointing to the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template). Passes the public Gateway name and namespace and the guestbook hostname as Helm values so child apps can bind their `HTTPRoute` to the correct Gateway

## Integration

- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: `aws_secret_store` and `aws_external_secret` depend on ESO being deployed and its IAM role being in place before creating the `SecretStore` and `ExternalSecret` resources
- **[`units/eks/addons/aws_load_balancer_controller`](../aws_load_balancer_controller/)**: `helm` waits for the controller to be ready so the ALB is provisioned correctly on first sync
- **[`units/eks/addons/external_dns`](../external_dns/)**: `helm` waits for ExternalDNS to be ready so DNS records are created on first sync
- **[`units/eks/route53`](../../route53/)**: `helm` reads the ACM certificate ARN for the ALB ingress and waits on the private hosted zone; `app_of_apps` waits on the public hosted zone
- **[`units/eks/addons/gateway_api`](../gateway_api/)**: `app_of_apps` reads the public Gateway name and namespace to inject them into child app Helm values
