# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the ExternalSecret resource"
  type        = string
}

variable "namespace" {
  description = "Namespace where the ExternalSecret lives"
  type        = string
}

variable "secret_store_name" {
  description = "Name of the SecretStore or ClusterSecretStore to reference"
  type        = string
}

variable "secret_store_kind" {
  description = "Kind of the secret store — SecretStore or ClusterSecretStore"
  type        = string
  default     = "SecretStore"
}

variable "target_secret_name" {
  description = "Name of the Kubernetes Secret to write into"
  type        = string
}

variable "target_creation_policy" {
  description = "Controls whether ESO creates or merges into the target Secret"
  type        = string
  default     = "Merge"
}

variable "refresh_policy" {
  description = "Controls when ESO re-syncs the secret — CreatedOnce, Periodic, or OnChange"
  type        = string
  default     = "CreatedOnce"
}

variable "data" {
  description = "Mappings from Secrets Manager fields to Kubernetes Secret keys"
  type = list(object({
    secret_key      = string
    remote_key      = string
    remote_property = string
  }))
}
