data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "lab/vpc/terraform.tfstate"
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

module "alb" {
  source = "../../../modules/alb"

  name                  = "${var.env}-shared-alb"
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids     = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  certificate_arn       = var.certificate_arn
  ingress_cidr_blocks   = var.ingress_cidr_blocks
  enable_waf            = var.enable_waf
  enable_legacy_ec2_asg = var.enable_legacy_ec2_asg
  is_lab                = var.is_lab
  default_tags          = local.default_tags
}
