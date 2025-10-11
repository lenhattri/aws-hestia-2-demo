data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "lab/vpc/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

locals {
  interface_endpoints = {
    ecr_api = {
      service                       = "ecr.api"
      additional_security_group_ids = var.additional_security_group_ids
    }
    ecr_dkr = {
      service                       = "ecr.dkr"
      additional_security_group_ids = var.additional_security_group_ids
    }
  }

  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = values(data.terraform_remote_state.vpc.outputs.private_route_table_ids)
    }
    dynamodb = {
      service         = "dynamodb"
      route_table_ids = values(data.terraform_remote_state.vpc.outputs.private_route_table_ids)
    }
  }

  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    ManagedBy = "terraform"
  }
}

module "endpoints" {
  source = "../../../modules/endpoints"

  name               = "${var.env}-network"
  region             = var.region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block     = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  interface_endpoints     = local.interface_endpoints
  gateway_endpoints       = local.gateway_endpoints
  enable_interface_vpce   = var.enable_interface_vpce
  enable_gateway_s3_ddb   = var.enable_gateway_s3_ddb
  is_lab                  = var.is_lab
  default_tags            = local.default_tags
}
