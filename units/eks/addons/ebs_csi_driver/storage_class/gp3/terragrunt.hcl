include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

include "provider_k8s_base" {
  path = find_in_parent_folders("provider_k8s_base.hcl")
}

include "provider_kubectl" {
  path = find_in_parent_folders("provider_kubectl.hcl")
}

terraform {
  source = "git::git@github.com:${include.root.locals.github_username_catalog}/${include.root.locals.github_repo_name_catalog}.git//modules/kubectl_manifest/?ref=${values.version}"
}

dependency "ebs_csi_driver_addon" {
  config_path  = "../../addon"
  skip_outputs = true
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  api_version  = "storage.k8s.io/v1"
  kind         = "StorageClass"
  name         = "gp3"
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "true"
  }
  fields = {
    provisioner          = "ebs.csi.aws.com"
    reclaimPolicy        = "Delete"
    volumeBindingMode    = "WaitForFirstConsumer"
    allowVolumeExpansion = true
    parameters = {
      type      = "gp3"
      fsType    = "ext4"
      encrypted = "true"
    }
  }
}
