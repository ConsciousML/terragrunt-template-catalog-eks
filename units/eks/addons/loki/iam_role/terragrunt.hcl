include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_owner_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_pod_identity/?ref=${values.version}"
}

dependency "eks_cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "s3_chunks" {
  config_path = "../s3/chunks"
  mock_outputs = {
    s3_bucket_arn = "arn:aws:s3:::mock-loki-chunks"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

dependency "s3_ruler" {
  config_path = "../s3/ruler"
  mock_outputs = {
    s3_bucket_arn = "arn:aws:s3:::mock-loki-ruler"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name    = dependency.eks_cluster.outputs.cluster_name
  iam_policy_name = "${include.root.locals.environment}-loki-policy"
  iam_role_name   = "${include.root.locals.environment}-loki"
  namespace       = "loki" # must match the app-of-apps repo's helm-loki destination namespace
  service_account = "loki" # must match the app-of-apps repo's helm-loki tool.helm.releaseName

  iam_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Resource = [
          dependency.s3_chunks.outputs.s3_bucket_arn,
          "${dependency.s3_chunks.outputs.s3_bucket_arn}/*",
          dependency.s3_ruler.outputs.s3_bucket_arn,
          "${dependency.s3_ruler.outputs.s3_bucket_arn}/*",
        ]
      },
    ]
  })

  tags = values.tags
}
