# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "api_version" {
  description = "API version of the Kubernetes resource (e.g. gateway.networking.k8s.io/v1)"
  type        = string
}

variable "kind" {
  description = "Kind of the Kubernetes resource (e.g. Gateway, GatewayClass)"
  type        = string
}

variable "name" {
  description = "Name of the Kubernetes resource"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy the resource into; omit for cluster-scoped resources"
  type        = string
  default     = null
}

variable "annotations" {
  description = "Annotations to set on the resource's metadata"
  type        = map(string)
  default     = null
}

variable "fields" {
  description = "Top-level fields merged into the manifest alongside apiVersion/kind/metadata (e.g. `{ spec = {...} }` for spec/status CRDs, or provisioner/parameters directly for built-in types like StorageClass)"
  type        = any
}
