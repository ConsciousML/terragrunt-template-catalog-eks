<!-- BEGIN_TF_DOCS -->
# HTTP Fetch

Fetches a URL and exposes the response body as an output.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | = 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | = 3.6.0 |

## Resources

| Name | Type |
|------|------|
| [http_http.this](https://registry.terraform.io/providers/hashicorp/http/3.6.0/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_url"></a> [url](#input\_url) | URL to fetch | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_body"></a> [body](#output\_body) | Response body of the HTTP request |
<!-- END_TF_DOCS -->