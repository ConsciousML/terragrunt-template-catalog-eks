# The environment where to deploy the infrastructure, i.e `dev`, `staging`, etc.
# The env name will prefix the S3 bucket name storing the tfstates
# as well as resource names to avoid collision
# Override by setting TG_ENVIRONMENT env var (e.g. TG_ENVIRONMENT=catalog-eks-ci in CI)
locals {
  environment = get_env("TG_ENVIRONMENT", "dev")
}
