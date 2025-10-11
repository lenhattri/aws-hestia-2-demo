data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "stage/vpc/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

locals {
  interface_endpoints = {
    sts = {
      service                       = "sts"
      additional_security_group_ids = var.additional_security_group_ids
    }
    secretsmanager = {
      service                       = "secretsmanager"
      additional_security_group_ids = var.additional_security_group_ids
    }
    ecr_api = {
      service                       = "ecr.api"
      additional_security_group_ids = var.additional_security_group_ids
    }
    ecr_dkr = {
      service                       = "ecr.dkr"
      additional_security_group_ids = var.additional_security_group_ids
    }
    logs = {
      service                       = "logs"
      additional_security_group_ids = var.additional_security_group_ids
    }
    ssm = {
      service                       = "ssm"
      additional_security_group_ids = var.additional_security_group_ids
    }
    ssmmessages = {
      service                       = "ssmmessages"
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
      route_table_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    }
  }
}

module "endpoints" {
  source = "../../../modules/endpoints"

  name               = "${var.env}-network"
  region             = var.region
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block     = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  interface_endpoints = local.interface_endpoints
  gateway_endpoints   = local.gateway_endpoints

  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}
