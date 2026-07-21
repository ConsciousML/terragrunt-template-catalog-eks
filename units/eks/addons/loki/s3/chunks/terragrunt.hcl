include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws?version=${values.version}"
}

inputs = {
  bucket = "${include.root.locals.environment}-loki-chunks"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = values.tags
}
