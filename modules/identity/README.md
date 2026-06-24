<!-- BEGIN_TF_DOCS -->
# Identity Module

Passes an input string through as an output, making it addressable as a Terraform state output.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.1 |

## Providers

No providers.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_value"></a> [value](#input\_value) | Value to pass through | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_value"></a> [value](#output\_value) | Passthrough value |
<!-- END_TF_DOCS -->