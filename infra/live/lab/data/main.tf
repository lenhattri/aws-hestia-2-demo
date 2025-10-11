data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "lab/vpc/terraform.tfstate"
    region = var.backend_region
  }
}

data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = var.backend_bucket
    key    = "lab/s3/terraform.tfstate"
    region = var.backend_region
  }
}

locals {
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    ManagedBy = "terraform"
  }

  firehose_log_group_name = "/aws/kinesis-firehose/${var.env}/telemetry"
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = local.firehose_log_group_name
  retention_in_days = var.cloudwatch_log_retention_days
  tags              = merge(local.default_tags, { Module = "logs" })
}

module "aurora" {
  source = "../../../modules/rds"

  name                = "${var.env}-aurora"
  vpc_id              = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids          = data.terraform_remote_state.vpc.outputs.isolated_subnet_ids
  allowed_cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  database_name       = var.database_name
  instance_class      = var.rds_instance_class
  instance_count      = 1
  storage_kms_key_arn = data.terraform_remote_state.s3.outputs.kms_key_arn
  secrets_kms_key_arn = data.terraform_remote_state.s3.outputs.kms_key_arn
  is_lab              = var.is_lab
  rds_deployment      = var.rds_deployment
  enable_rds_proxy    = var.enable_rds_proxy
  default_tags        = local.default_tags
}

module "telemetry_table" {
  source = "../../../modules/dynamodb"

  table_name              = var.dynamodb_table_name
  kms_key_arn             = data.terraform_remote_state.s3.outputs.kms_key_arn
  is_lab                  = var.is_lab
  dynamodb_billing_mode   = var.dynamodb_billing_mode
  default_tags            = local.default_tags
}

module "telemetry_stream" {
  source = "../../../modules/kinesis"

  stream_name             = var.stream_name
  shard_count             = var.kinesis_shards
  kms_key_arn             = data.terraform_remote_state.s3.outputs.kms_key_arn
  firehose_bucket_name    = data.terraform_remote_state.s3.outputs.telemetry_bucket
  firehose_log_group_name = aws_cloudwatch_log_group.firehose.name
  firehose_log_group_arn  = aws_cloudwatch_log_group.firehose.arn
  glue_database_name      = "${var.env}_telemetry"
  glue_table_name         = "events"
  is_lab                  = var.is_lab
  kinesis_mode            = var.kinesis_mode
  kinesis_shards          = var.kinesis_shards
  default_tags            = local.default_tags
}
