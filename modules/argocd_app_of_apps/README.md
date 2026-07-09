<!-- BEGIN_TF_DOCS -->
# ArgoCD App of Apps

Creates an ArgoCD [`Application`](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#applications) resource that acts as the root of an app-of-apps pattern. ArgoCD syncs this Application, which in turn discovers and deploys all child Applications from the configured repository path.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 3.1.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.1.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/3.1.1/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster, used to configure the Kubernetes provider | `string` | n/a | yes |
| <a name="input_destination_namespace"></a> [destination\_namespace](#input\_destination\_namespace) | Kubernetes namespace ArgoCD will deploy child applications into | `string` | `"argocd"` | no |
| <a name="input_destination_server"></a> [destination\_server](#input\_destination\_server) | Kubernetes API server URL of the destination cluster | `string` | `"https://kubernetes.default.svc"` | no |
| <a name="input_finalizers"></a> [finalizers](#input\_finalizers) | List of finalizers applied to the Application resource | `list(string)` | <pre>[<br/>  "resources-finalizer.argocd.argoproj.io"<br/>]</pre> | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | Version of the argo-helm/argocd-apps chart to install | `string` | n/a | yes |
| <a name="input_helm_values"></a> [helm\_values](#input\_helm\_values) | Helm values injected into spec.source.helm.values on the app-of-apps Application | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ArgoCD Application resource | `string` | `"app-of-apps"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace where the ArgoCD Application resource is created | `string` | `"argocd"` | no |
| <a name="input_path"></a> [path](#input\_path) | Path within the repository containing the application manifests | `string` | `"apps"` | no |
| <a name="input_project"></a> [project](#input\_project) | ArgoCD project the Application belongs to | `string` | `"default"` | no |
| <a name="input_prune"></a> [prune](#input\_prune) | Whether ArgoCD should delete resources that are no longer tracked | `bool` | `true` | no |
| <a name="input_repo_url"></a> [repo\_url](#input\_repo\_url) | Git repository URL that ArgoCD will sync from | `string` | n/a | yes |
| <a name="input_sync_options"></a> [sync\_options](#input\_sync\_options) | List of ArgoCD sync options | `list(string)` | <pre>[<br/>  "CreateNamespace=true"<br/>]</pre> | no |
| <a name="input_target_revision"></a> [target\_revision](#input\_target\_revision) | Git branch, tag, or commit SHA to sync | `string` | `"main"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->