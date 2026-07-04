<!-- BEGIN_TF_DOCS -->
# Kubectl Manifest From URL

Fetches a URL containing one or more YAML manifests and applies each resource to Kubernetes using server-side apply.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.6 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | ~> 2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.6 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 2.4 |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.this](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [http_http.this](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [kubectl_file_documents.this](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/data-sources/file_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster — consumed by the generated provider | `string` | n/a | yes |
| <a name="input_url"></a> [url](#input\_url) | URL of the YAML manifest(s) to fetch and apply | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->