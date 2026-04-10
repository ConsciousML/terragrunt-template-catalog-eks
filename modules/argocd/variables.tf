variable "host" {
  description = "The hostname (in form of URI) of the Kubernetes API. Can be sourced from `KUBE_HOST`"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "PEM-encoded root certificates bundle for TLS authentication. Can be sourced from `KUBE_CLUSTER_CA_CERT_DATA`"
  type        = string
}

variable "token" {
  description = "Token of your service account. Can be sourced from `KUBE_TOKEN`"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}