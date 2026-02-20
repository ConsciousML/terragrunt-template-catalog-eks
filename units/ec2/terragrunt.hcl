include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment_hcl = find_in_parent_folders("environment.hcl")
  environment     = read_terragrunt_config(local.environment_hcl).locals.environment
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    subnet_id = "subnet-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "destroy"]
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-catalog-aws.git//modules/ec2?ref=${values.version}"
}

inputs = {
  subnet_id     = dependency.subnet.outputs.subnet_id
  ami           = values.ami
  instance_type = values.instance_type
  tags = {
    environment = "${local.environment}"
  }
}
