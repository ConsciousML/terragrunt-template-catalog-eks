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

dependency "ec2_node_class" {
  config_path = "../ec2_node_class"
  mock_outputs = {
    name = "default"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  cluster_name = dependency.eks_cluster.outputs.cluster_name
  api_version  = "karpenter.sh/v1"
  kind         = "NodePool"
  name         = "default"
  # nodeClassRef is injected here rather than passed via values so the NodePool always
  # references the actual EC2NodeClass name resolved from its dependency output,
  # avoiding hardcoding the name in the stack.
  fields = {
    spec = merge(values.spec, {
      template = merge(values.spec.template, {
        spec = merge(values.spec.template.spec, {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = dependency.ec2_node_class.outputs.name
          }
        })
      })
    })
  }
}
