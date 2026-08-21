locals {
  # Offset within each private subnet CIDR for each interface endpoint's pinned ENI IP.
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
}
