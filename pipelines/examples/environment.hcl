# The environment where to deploy the infrastructure, i.e `dev`, `staging`, ect.
# The env name will prefix the GCS bucket name storing the tfstates
# as well as some resource variables to avoid collision
# Override by setting TG_ENVIRONMENT env var (e.g. TG_ENVIRONMENT=catalog-eks-ci in CI)
locals {
  environment = get_env("TG_ENVIRONMENT", "example")
}
