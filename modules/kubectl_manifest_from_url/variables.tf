variable "url" {
  description = "URL of the YAML manifest(s) to fetch and apply"
  type        = string
}

# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster — consumed by the generated provider"
  type        = string
}
