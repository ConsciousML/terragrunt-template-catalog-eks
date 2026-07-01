# k8s Manifest

Creates a generic Kubernetes manifest resource. Callers supply `api_version`, `kind`, and `fields` (merged alongside `apiVersion`/`kind`/`metadata`); the module applies them via the `kubernetes_manifest` Terraform resource. Works for both spec/status CRDs (pass `fields = { spec = {...} }`) and built-in types with top-level fields (e.g. `StorageClass`).
