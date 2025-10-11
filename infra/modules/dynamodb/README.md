# DynamoDB Module

Creates the telemetry pipeline store used by AWS IoT Core rule actions. The table is optimized for time-series ingestion with TTL, streaming, and optional GSIs for query fan-out.

## Features
- PAY_PER_REQUEST billing with optional GSI definitions
- TTL-based expiry to control table growth
- Streams enabled for downstream processors (Kinesis Firehose)
- Customer-managed KMS encryption

## Usage
```hcl
module "telemetry" {
  source = "../../modules/dynamodb"

  table_name  = "${var.env}-iot-telemetry"
  kms_key_arn = aws_kms_key.data.arn
  default_tags = var.default_tags
}
```

Outputs include the table name and stream ARN used by the Kinesis consumer stack.
