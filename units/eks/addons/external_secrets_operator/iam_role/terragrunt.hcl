include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/iam_pod_identity/?ref=${values.version}"
}

dependency "eks_cluster" {
  config_path = "../../../cluster"
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name    = dependency.eks_cluster.outputs.cluster_name
  iam_policy_name = "${include.root.locals.environment}-external-secrets-operator-policy"
  iam_role_name   = "${include.root.locals.environment}-external-secrets-operator"
  namespace       = "external-secrets"
  service_account = "external-secrets"

  iam_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:ListSecrets", "secretsmanager:BatchGetSecretValue"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
        ]
        Resource = ["arn:aws:secretsmanager:*:*:secret:${include.root.locals.environment}-*"]
      },
    ]
  })

  tags = values.tags
}
