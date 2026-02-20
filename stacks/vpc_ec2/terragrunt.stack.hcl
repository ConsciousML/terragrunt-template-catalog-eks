unit "vpc" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//units/vpc?ref=${values.version}"
  path   = "vpc"

  values = {
    version            = values.version
    cidr_block         = values.cidr_block_vpc
    enable_dns_support = values.enable_dns_support
  }
}

unit "subnet" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//units/subnet?ref=${values.version}"
  path   = "subnet"

  values = {
    version    = values.version
    cidr_block = values.cidr_block_subnet
    zone       = values.zone
  }
}

unit "ec2" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//units/ec2?ref=${values.version}"
  path   = "ec2"

  values = {
    version       = values.version
    ami           = values.ec2_ami
    instance_type = values.ec2_instance_type
  }
}