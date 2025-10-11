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

resource "aws_kms_key" "data" {
  description             = "${var.env} data plane encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
    Module    = "kms"
  }
}

resource "aws_kms_alias" "data" {
  name          = "alias/${var.env}/hestia/data"
  target_key_id = aws_kms_key.data.key_id
}

resource "aws_kms_key" "secrets" {
  description             = "${var.env} secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
    Module    = "kms"
  }
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.env}/hestia/secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesis-firehose/${var.env}/telemetry"
  retention_in_days = 90
  kms_key_id        = aws_kms_key.data.arn
  tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
    Module    = "logs"
  }
}

module "data_lake" {
  source = "../../../modules/s3"

  env          = var.env
  kms_key_arn  = aws_kms_key.data.arn
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}

module "aurora" {
  source = "../../../modules/rds"

  name                  = "${var.env}-aurora"
  vpc_id                = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids            = data.terraform_remote_state.vpc.outputs.isolated_subnet_ids
  allowed_cidr_blocks   = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  database_name         = var.database_name
  instance_class        = var.aurora_instance_class
  instance_count        = var.aurora_instance_count
  storage_kms_key_arn   = aws_kms_key.data.arn
  secrets_kms_key_arn   = aws_kms_key.secrets.arn
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}

module "telemetry_table" {
  source = "../../../modules/dynamodb"

  table_name  = var.dynamodb_table_name
  kms_key_arn = aws_kms_key.data.arn
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}

module "telemetry_stream" {
  source = "../../../modules/kinesis"

  stream_name             = var.stream_name
  shard_count             = 2
  kms_key_arn             = aws_kms_key.data.arn
  firehose_bucket_name    = module.data_lake.telemetry_bucket_name
  firehose_log_group_name = aws_cloudwatch_log_group.firehose.name
  firehose_log_group_arn  = aws_cloudwatch_log_group.firehose.arn
  glue_database_name      = "${var.env}_telemetry"
  glue_table_name         = "events"
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }
}
