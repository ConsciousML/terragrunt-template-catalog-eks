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
- **[`argocd-secrets`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-eso-secret-sync)** (app-of-apps): an instance of the generic `helm-eso-secret-sync` chart, syncs the admin password's bcrypt hash into `argocd-secret` via an ESO `SecretStore` and `ExternalSecret`. Not deployed by this unit
- **[`argocd-server-grpc-service`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/argocd-server-grpc-service)** (app-of-apps): the ArgoCD server's gRPC `Service` and its `TargetGroupConfiguration`. Not deployed by the `helm` unit above
- **[`argocd-httproute`](https://github.com/ConsciousML/argocd-app-of-apps-template/tree/main/helm-httproute)** (app-of-apps): an instance of the generic `helm-httproute` chart, routes ArgoCD through the shared private `Gateway`. Not deployed by the `helm` unit above

See the [App of Apps integration guide](../../../../docs/app-of-apps-integration.md) to understand how these apps are wired to Terraform-sourced values.

## Upstream Dependencies

### [Helm Unit](helm/)

- **[`units/eks/addons/prometheus_stack/crds`](../prometheus_stack/crds/)**: depends on it so the Prometheus Operator CRDs exist before ArgoCD's own Helm release renders any `ServiceMonitor`
- **[`units/eks/route53`](../../route53/)**: depends on the private hosted zone

### [App of Apps Unit](app_of_apps/)

- **[`units/vpc`](../../../vpc/)**: reads `vpc_id` and `vpc_cidr_block` to configure `helm-aws-lbc` and `helm-tailscale-connector`
- **[`units/eks/addons/prometheus_stack`](../prometheus_stack/)**: reads the `grafana/aws_secret_password` and `alertmanager/aws_secret_slack_bot` secret names to configure `grafana-secrets` and `alertmanager-secrets`
- **[`units/eks/addons/external_secrets_operator`](../external_secrets_operator/)**: depends on its IAM role so the ESO controller can read the admin password secret once deployed through app-of-apps
- **[`units/eks/addons/aws_load_balancer_controller`](../aws_load_balancer_controller/)**: depends on its IAM role so the Pod Identity association exists before ArgoCD deploys the controller
- **[`units/eks/addons/external_dns`](../external_dns/)**: depends on both IAM roles so the Pod Identity associations exist before ArgoCD deploys either instance
- **[`units/eks/addons/loki`](../loki/)**: reads the chunks and ruler S3 bucket IDs to configure `helm-loki`, and depends on `iam_role` so Loki's Pod Identity association exists before ArgoCD deploys it
- **[`units/eks/addons/ebs_csi_driver`](../ebs_csi_driver/)**: depends on `addon` so `PersistentVolumeClaim` provisioning is available before ArgoCD deploys workloads that request storage
- **[`units/eks/route53`](../../route53/)**: waits on both hosted zones so the ACM certificate exists before app-of-apps deploys `gateway-public` and `gateway-private`
- **[`units/eks/addons/karpenter`](../karpenter/)**: depends on `iam`, `helm`, `ec2_node_class`, and `node_pool/elastic` so the interruption queue, node IAM role, and node pool config exist before ArgoCD deploys anything that schedules onto Karpenter-provisioned nodes
- **[`units/eks/addons/tailscale/oauth_client_secret`](../tailscale/oauth_client_secret/)**: depends on it so the OAuth credentials exist before app-of-apps deploys `tailscale-secrets`
