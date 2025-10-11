locals {
  merged_tags = merge(var.default_tags, {
    Module = "kinesis"
  })

  effective_shard_count = var.is_lab ? var.kinesis_shards : var.shard_count
  effective_stream_mode = upper(var.is_lab ? var.kinesis_mode : var.stream_mode)
}

resource "aws_kinesis_stream" "this" {
  name             = var.stream_name
  shard_count      = local.effective_shard_count
  retention_period = var.retention_hours
  encryption_type  = "KMS"
  kms_key_id       = var.kms_key_arn
  stream_mode_details {
    stream_mode = local.effective_stream_mode
  }
  tags = local.merged_tags
}

resource "aws_glue_catalog_database" "this" {
  name = var.glue_database_name
}

resource "aws_glue_catalog_table" "this" {
  name          = var.glue_table_name
  database_name = aws_glue_catalog_database.this.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    classification = "parquet"
  }

  storage_descriptor {
    location      = "s3://${var.firehose_bucket_name}/${var.firehose_prefix}"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "ParquetSerDe"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name = "deviceid"
      type = "string"
    }

    columns {
      name = "timestamp"
      type = "string"
    }

    columns {
      name = "payload"
      type = "string"
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = "${var.stream_name}-firehose"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "firehose" {
  name   = "${var.stream_name}-firehose"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose.json
}

data "aws_iam_policy_document" "firehose" {
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.firehose_bucket_name}",
      "arn:aws:s3:::${var.firehose_bucket_name}/${var.firehose_prefix}*"
    ]
  }

  statement {
    actions   = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }

  statement {
    actions   = ["logs:PutLogEvents"]
    resources = ["${var.firehose_log_group_arn}:*"]
  }
}

resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = "${var.stream_name}-firehose"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.this.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    bucket_arn         = "arn:aws:s3:::${var.firehose_bucket_name}"
    prefix             = var.firehose_prefix
    error_output_prefix = "errors/!{timestamp:yyyy/MM/dd}/"
    buffer_interval    = 300
    buffer_size        = 128
    compression_format = "GZIP"
    kms_key_arn        = var.kms_key_arn
    role_arn           = aws_iam_role.firehose.arn
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = var.firehose_log_group_name
      log_stream_name = "delivery"
    }

    data_format_conversion_configuration {
      enabled = true

      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_database.this.name
        table_name    = aws_glue_catalog_table.this.name
        role_arn      = aws_iam_role.firehose.arn
      }
    }
  }

  tags = local.merged_tags
}

output "stream_arn" {
  description = "ARN of the Kinesis data stream."
  value       = aws_kinesis_stream.this.arn
}

output "firehose_arn" {
  description = "ARN of the Firehose delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.this.arn
}

output "glue_table_name" {
  description = "Glue table receiving telemetry schema."
  value       = aws_glue_catalog_table.this.name
}
