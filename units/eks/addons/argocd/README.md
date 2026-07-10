# ArgoCD

Deploys ArgoCD into the cluster and wires up its admin password via AWS Secrets Manager and the External Secrets Operator, then bootstraps GitOps application delivery via the App of Apps pattern.

## Concepts

- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [App of Apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [External Secret Operator (ESO)](https://external-secrets.io/latest/)
- [ESO SecretStore](https://external-secrets.io/latest/api/secretstore/)
- [ESO ExternalSecret](https://external-secrets.io/latest/api/externalsecret/)

## What's Inside

- **[aws_secret_password](aws_secret_password/)**: Generates a random admin password and stores it in AWS Secrets Manager. Its `secret_name` output flows into `app_of_apps`
- **[helm](helm/)**: Deploys ArgoCD via Helm. Sets `global.domain` from `domains.hcl` and attaches the ACM certificate ARN to the ALB ingress annotation for TLS termination on HTTPS
- **[app_of_apps](app_of_apps/)**: Deploys the root ArgoCD `Application` CR pointing to the [App of Apps repository](https://github.com/ConsciousML/argocd-app-of-apps-template). Passes the ACM certificate ARN, guestbook hostname, and the admin password secret name as Helm values

The ESO `SecretStore`/`ExternalSecret` that sync the admin password's bcrypt hash into `argocd-secret` are deployed through app-of-apps (`argocd-secrets`, an instance of the generic [`helm-eso-secret-sync`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync) chart), not Terraform. See the [App of Apps integration guide](../../../../docs/app_of_apps_integration.md).

## Integration

- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: its IAM role must be in place before the ESO controller (deployed through app-of-apps) can read the admin password secret
- **[`units/eks/addons/aws_load_balancer_controller`](../aws_load_balancer_controller/)**: `helm` waits for the controller to be ready so the ALB is provisioned correctly on first sync
- **[`units/eks/addons/external_dns`](../external_dns/)**: `helm` waits for ExternalDNS to be ready so DNS records are created on first sync
- **[`units/eks/route53`](../../route53/)**: `helm` reads the ACM certificate ARN for the ALB ingress and waits on the private hosted zone; `app_of_apps` waits on the public hosted zone and passes the certificate ARN to app-of-apps's `helm-gateway-api` app
