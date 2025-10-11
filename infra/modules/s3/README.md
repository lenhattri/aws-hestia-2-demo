# S3 Module

Creates the S3 buckets required for the telemetry lake, firmware distribution, and centralized logs. Buckets follow the mandated naming convention and enforce KMS encryption plus TLS-only access.

## Features
- Deterministic bucket naming per environment
- Versioning enabled across all buckets
- Lifecycle policies for telemetry tiering and log retention
- Secure transport bucket policies and public access blocks

## Usage
```hcl
module "data_lake" {
  source = "../../modules/s3"

  env          = var.env
  kms_key_arn  = aws_kms_key.data.arn
  default_tags = var.default_tags
}
```

Outputs provide the bucket names for downstream modules (Firehose, firmware CI/CD, logging).
