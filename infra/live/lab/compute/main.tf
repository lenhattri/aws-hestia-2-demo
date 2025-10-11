data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "lab/vpc/terraform.tfstate"
    region = var.backend_region
  }
}

data "terraform_remote_state" "ingress" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "lab/ingress/terraform.tfstate"
    region = var.backend_region
  }
}

locals {
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    ManagedBy = "terraform"
  }
}

module "compute" {
  source = "../../../modules/ec2"

  name                   = "${var.env}-compute"
  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  bastion_subnet_ids     = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  legacy_subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  alb_target_group_arn   = coalesce(try(data.terraform_remote_state.ingress.outputs.eks_target_group_arn, ""), "")
  alb_security_group_id  = coalesce(try(data.terraform_remote_state.ingress.outputs.alb_security_group_id, ""), "")
  bastion_instance_type  = var.bastion_instance_type
  enable_ssm_bastion     = var.enable_ssm_bastion
  enable_legacy_ec2_asg  = var.enable_legacy_ec2_asg
  is_lab                 = var.is_lab
  default_tags           = local.default_tags
}
