include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  environment = include.root.locals.environment
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
