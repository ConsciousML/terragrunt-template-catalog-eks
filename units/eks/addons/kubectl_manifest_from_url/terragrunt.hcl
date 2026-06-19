include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_kubernetes" {
  path   = find_in_parent_folders("provider_kubernetes.hcl")
  expose = true
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/kubectl_manifest_from_url/?ref=${values.version}"
}

inputs = {
  url          = values.url
  cluster_name = dependency.eks_cluster.outputs.cluster_name
}
