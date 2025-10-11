data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnets = [
    for idx, az in local.selected_azs : {
      az         = az
      cidr       = cidrsubnet(var.cidr_block, 4, idx)
      create_nat = idx == 0
    }
  ]

  private_subnets = [
    for idx, az in local.selected_azs : {
      az   = az
      cidr = cidrsubnet(var.cidr_block, 4, idx + 4)
    }
  ]

  isolated_subnets = [
    for idx, az in local.selected_azs : {
      az   = az
      cidr = cidrsubnet(var.cidr_block, 4, idx + 8)
    }
  ]

  default_tags = merge({
    App       = "aws-hestia-system-demo",
    Env       = var.env,
    ManagedBy = "terraform"
  }, var.extra_tags)
}

module "vpc" {
  source = "../../../modules/vpc"
  name   = var.name_prefix

  cidr_block           = var.cidr_block
  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  isolated_subnets     = local.isolated_subnets
  enable_nat_gateway   = var.enable_nat_gateway
  az_count             = var.az_count
  is_lab               = var.is_lab
  cloudwatch_log_retention_days =  var.is_lab ? 3 : 30
  default_tags         = local.default_tags
}
