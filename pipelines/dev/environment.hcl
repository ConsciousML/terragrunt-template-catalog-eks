# The environment where to deploy the infrastructure, i.e `dev`, `staging`, etc.
# The env name will prefix the S3 bucket name storing the tfstates
# as well as resource names to avoid collision
# Override by setting TG_ENVIRONMENT env var (e.g. TG_ENVIRONMENT=catalog-eks-ci in CI)

# The environment name exposed to Helm as global.environment. Lets an environment reuse
# another one's Helm value overlays (e.g. dev-2 aliasing to dev) while keeping its own
# tfstate and resource prefix.
# Override by setting TG_ENVIRONMENT_ALIAS env var (e.g. TG_ENVIRONMENT_ALIAS=dev in CI)
locals {
  environment       = get_env("TG_ENVIRONMENT", "dev")
  environment_alias = get_env("TG_ENVIRONMENT_ALIAS", local.environment)
}
