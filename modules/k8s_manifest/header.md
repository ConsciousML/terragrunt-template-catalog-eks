# k8s Manifest

Creates a generic Kubernetes manifest resource. Callers supply `api_version`, `kind`, and `spec`; the module applies them via the `kubernetes_manifest` Terraform resource.
