data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "prod/vpc/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "ingress" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "prod/ingress/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "prod/data/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

locals {
  tags = merge({
    App       = "aws-hestia-system-demo",
    Env       = var.env,
    Owner     = "platform",
    ManagedBy = "terraform"
  }, var.extra_tags)
}

module "compute" {
  source = "../../../modules/ec2"

  name                  = "${var.env}-compute"
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  bastion_subnet_ids    = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  legacy_subnet_ids     = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  alb_target_group_arn  = data.terraform_remote_state.ingress.outputs.ec2_target_group_arn
  alb_security_group_id = data.terraform_remote_state.ingress.outputs.alb_security_group_id
  bastion_instance_type = var.bastion_instance_type
  legacy_instance_type  = var.legacy_instance_type
  legacy_desired_capacity = var.legacy_desired_capacity
  legacy_min_size         = var.legacy_min_size
  legacy_max_size         = var.legacy_max_size
  default_tags          = locals.tags
}

resource "aws_iam_role" "iot_provisioning" {
  name               = var.provisioning_role_name
  assume_role_policy = data.aws_iam_policy_document.iot_provisioning_assume.json
  tags               = locals.tags
}

data "aws_iam_policy_document" "iot_provisioning_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iot_provisioning" {
  statement {
    effect = "Allow"
    actions = [
      "iot:CreateThing",
      "iot:DescribeThing",
      "iot:UpdateThing",
      "iot:AttachThingPrincipal",
      "iot:AttachPolicy",
      "iot:DescribeCertificate",
      "iot:UpdateCertificate"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "iot_provisioning" {
  role   = aws_iam_role.iot_provisioning.id
  policy = data.aws_iam_policy_document.iot_provisioning.json
}

module "iot" {
  source = "../../../modules/iot"

  name                      = "${var.env}-iot"
  kinesis_stream_arn        = data.terraform_remote_state.data.outputs.kinesis_stream_arn
  kinesis_kms_key_arn       = data.terraform_remote_state.data.outputs.data_kms_key_arn
  rule_sql                  = var.iot_rule_sql
  partition_key_template    = var.iot_partition_key_template
  provisioning_role_arn     = aws_iam_role.iot_provisioning.arn
  default_tags              = locals.tags
}
