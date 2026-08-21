include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment

  # Offset within each private subnet CIDR for each endpoint's pinned ENI IP.
  # ecr.dkr is provisioned for NAT cost savings only. No CiliumNetworkPolicy consumes it
  # (node image pulls go through kubelet, not a pod's Cilium endpoint). It has no
  # app_param_key_map entry below.
  endpoint_host_offsets = {
    secretsmanager       = 10
    route53              = 11
    "ecr.api"            = 12
    "ecr.dkr"            = 13
    ec2                  = 14
    sts                  = 15
    elasticloadbalancing = 16
    sqs                  = 17
  }

  # Consumer-side keys matching the awsEndpointCidrs shape expected by the
  # network-policies-aws-endpoints app in argocd-app-of-apps-template.
  app_param_key_map = {
    secretsmanager       = "secretsmanager"
    route53              = "route53"
    "ecr.api"            = "ecrApi"
    ec2                  = "ec2"
    sts                  = "sts"
    elasticloadbalancing = "elasticloadbalancing"
    sqs                  = "sqs"
  }

  interface_endpoints = {
    for svc, offset in local.endpoint_host_offsets : svc => {
      service    = svc
      subnet_ids = dependency.vpc.outputs.private_subnets
      subnet_configurations = [
        for i, cidr in dependency.vpc.outputs.private_subnets_cidr_blocks : {
          ipv4      = cidrhost(cidr, offset)
          subnet_id = dependency.vpc.outputs.private_subnets[i]
        }
      ]
    }
  }

  # Gateway endpoint, route table prefix-list entry, no ENI, no IP to pin.
  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = dependency.vpc.outputs.private_route_table_ids
    }
  }

  endpoints = merge(local.interface_endpoints, local.gateway_endpoints)
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc//modules/vpc-endpoints?version=${values.version}"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                      = "mock-vpc-id"
    private_subnets             = ["mock-subnet-1", "mock-subnet-2", "mock-subnet-3"]
    private_subnets_cidr_blocks = ["10.2.0.0/19", "10.2.32.0/19", "10.2.64.0/19"]
    private_route_table_ids     = ["mock-rt-1", "mock-rt-2", "mock-rt-3"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

inputs = {
  vpc_id    = dependency.vpc.outputs.vpc_id
  endpoints = local.endpoints

  tags = {
    environment = "${local.environment}"
  }
}

output "aws_endpoint_cidrs" {
  value = {
    for svc, key in local.app_param_key_map :
    key => cidrhost(dependency.vpc.outputs.private_subnets_cidr_blocks[0], local.endpoint_host_offsets[svc])
  }
}
