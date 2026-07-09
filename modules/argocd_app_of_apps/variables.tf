# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of the EKS cluster, used to configure the Kubernetes provider"
  type        = string
}

variable "name" {
  description = "Name of the ArgoCD Application resource"
  type        = string
  default     = "app-of-apps"
}

variable "namespace" {
  description = "Namespace where the ArgoCD Application resource is created"
  type        = string
  default     = "argocd"
}

variable "finalizers" {
  description = "List of finalizers applied to the Application resource"
  type        = list(string)
  default     = ["resources-finalizer.argocd.argoproj.io"]
}

variable "repo_url" {
  description = "Git repository URL that ArgoCD will sync from"
  type        = string
}

variable "path" {
  description = "Path within the repository containing the application manifests"
  type        = string
  default     = "apps"
}

variable "target_revision" {
  description = "Git branch, tag, or commit SHA to sync"
  type        = string
  default     = "main"
}

variable "project" {
  description = "ArgoCD project the Application belongs to"
  type        = string
  default     = "default"
}

variable "destination_namespace" {
  description = "Kubernetes namespace ArgoCD will deploy child applications into"
  type        = string
  default     = "argocd"
}

variable "destination_server" {
  description = "Kubernetes API server URL of the destination cluster"
  type        = string
  default     = "https://kubernetes.default.svc"
}

variable "sync_options" {
  description = "List of ArgoCD sync options"
  type        = list(string)
  default     = ["CreateNamespace=true"]
}

variable "prune" {
  description = "Whether ArgoCD should delete resources that are no longer tracked"
  type        = bool
  default     = true
}

variable "helm_values" {
  description = "Helm values injected into spec.source.helm.values on the app-of-apps Application"
  type        = any
  default     = {}
}

variable "helm_chart_version" {
  description = "Version of the argo-helm/argocd-apps chart to install"
  type        = string
}

variable "retry" {
  description = "Retry policy for the app-of-apps Application's sync operation. Defaults raised above ArgoCD's own defaults (limit 5, maxDuration 3m) so slow-starting sync waves (e.g. a component's first rollout) have enough runway to go Healthy before the sync gives up."
  type = object({
    limit = number
    backoff = object({
      duration     = string
      factor       = number
      max_duration = string
    })
  })
  default = {
    limit = 7
    backoff = {
      duration     = "5s"
      factor       = 2
      max_duration = "2m"
    }
  }
}
