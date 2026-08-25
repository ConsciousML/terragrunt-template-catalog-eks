include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment

  vpc_full_name = read_terragrunt_config(find_in_parent_folders("vpc.hcl")).locals.vpc_full_name

  # The fck-nat module's data "aws_vpc" "main" does a real AWS lookup on var.vpc_id, unlike
  # most units it can't tolerate a mocked dependency. Skip plan/validate until the VPC unit
  # has actually been applied, same pattern as provider_k8s_base.hcl's cluster_exists check.
  vpc_exists = run_cmd("--terragrunt-quiet", "sh", "-c", <<-EOT
    output=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${local.vpc_full_name}" --query 'Vpcs[0].VpcId' --output text 2>&1)
    aws_exit_code=$?
    if [ $aws_exit_code -ne 0 ]; then
      echo "$output" >&2
      exit 1
    elif [ "$output" = "None" ]; then
      echo false
    else
      echo true
    fi
  EOT
  )
}

terraform {
  source = "tfr:///RaJiska/fck-nat/aws?version=${values.version}"
}

dependency "vpc" {
  config_path = "../../vpc/vpc"
  mock_outputs = {
    vpc_id                  = "mock-vpc-id"
    public_subnets          = ["mock-subnet-1", "mock-subnet-2", "mock-subnet-3"]
    private_route_table_ids = ["mock-rt-1", "mock-rt-2", "mock-rt-3"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate", "graph", "destroy"]
}

exclude {
  if      = !local.vpc_exists
  actions = ["init", "validate", "plan", "destroy"]
}

inputs = {
  name      = "fck-nat-${local.environment}"
  vpc_id    = dependency.vpc.outputs.vpc_id
  subnet_id = dependency.vpc.outputs.public_subnets[0]

  ha_mode              = true
  update_route_tables  = true
  route_tables_ids     = { for idx, id in dependency.vpc.outputs.private_route_table_ids : "rtb-${idx}" => id }
  use_cloudwatch_agent = false

  tags = {
    environment = "${local.environment}"
  }
}
