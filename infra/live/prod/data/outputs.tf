output "data_kms_key_arn" {
  value       = aws_kms_key.data.arn
  description = "KMS key ARN for data encryption."
}

output "secrets_kms_key_arn" {
  value       = aws_kms_key.secrets.arn
  description = "KMS key ARN for secrets."
}

output "telemetry_bucket_name" {
  value       = module.data_lake.telemetry_bucket_name
  description = "Telemetry S3 bucket name."
}

output "firmware_bucket_name" {
  value       = module.data_lake.firmware_bucket_name
  description = "Firmware S3 bucket name."
}

output "logs_bucket_name" {
  value       = module.data_lake.logs_bucket_name
  description = "Logs S3 bucket name."
}

output "aurora_proxy_endpoint" {
  value       = module.aurora.proxy_endpoint
  description = "Aurora RDS proxy endpoint."
}

output "aurora_secret_arn" {
  value       = module.aurora.secret_arn
  description = "Secret storing Aurora credentials."
}

output "dynamodb_stream_arn" {
  value       = module.telemetry_table.stream_arn
  description = "DynamoDB stream ARN for telemetry table."
}

output "kinesis_stream_arn" {
  value       = module.telemetry_stream.stream_arn
  description = "Kinesis data stream ARN."
}
