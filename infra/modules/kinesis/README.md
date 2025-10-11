# Kinesis Module

Implements the telemetry streaming backbone connecting AWS IoT Core to the data lake. Raw records land in a Kinesis Data Stream, are transformed to Parquet by Firehose, and cataloged in Glue for Athena analytics.

## Features
- KMS-encrypted Kinesis Data Stream with configurable shards
- Firehose delivery stream converting JSON payloads to Parquet
- Glue database/table bootstrap for schema-on-read access
- IAM least privilege for Firehose to access S3, KMS, and CloudWatch Logs

## Usage
```hcl
module "telemetry_stream" {
  source = "../../modules/kinesis"

  stream_name           = "${var.env}-iot-telemetry"
  shard_count           = 2
  kms_key_arn           = aws_kms_key.data.arn
  firehose_bucket_name  = module.data_lake.telemetry_bucket_name
  firehose_log_group_name = aws_cloudwatch_log_group.firehose.name
  firehose_log_group_arn  = aws_cloudwatch_log_group.firehose.arn
  glue_database_name    = "${var.env}_telemetry"
  glue_table_name       = "events"
  default_tags          = var.default_tags
}
```

Outputs expose the stream ARN, Firehose ARN, and Glue table name for downstream consumers.
