unit "ec2_ondemand_quota" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/service_quota?ref=${values.version}"
  path   = "ec2_ondemand_quota"

  values = {
    version       = values.version
    service_code  = "ec2"
    quota_code    = "L-1216C47A" # Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances
    desired_value = values.ondemand_desired_value
  }
}

unit "ec2_spot_quota" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-eks.git//units/service_quota?ref=${values.version}"
  path   = "ec2_spot_quota"

  values = {
    version       = values.version
    service_code  = "ec2"
    quota_code    = "L-34B43A08" # All Standard (A, C, D, H, I, M, R, T, Z) Spot Instance Requests
    desired_value = values.spot_desired_value
  }
}
