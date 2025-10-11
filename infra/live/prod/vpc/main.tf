module "vpc" {
  source = "../../../modules/vpc"

  name               = var.name_prefix
  cidr_block         = var.cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  isolated_subnets   = var.isolated_subnets
  flow_log_kms_key_arn = var.flow_log_kms_key_arn
  default_tags       = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}
