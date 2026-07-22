include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=${values.version}"
}

inputs = {
  # Suffixed with the account ID and region for global S3 bucket-name uniqueness, same
  # pattern as the state bucket in pipelines/root.hcl.
  bucket = "${include.root.locals.environment}-loki-chunks-${get_aws_account_id()}-${include.root.locals.aws_region}"

  force_destroy = values.force_destroy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = values.tags
}
