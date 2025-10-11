output "telemetry_bucket" {
  value       = module.buckets.telemetry_bucket_name
  description = "Telemetry bucket name."
}

output "firmware_bucket" {
  value       = module.buckets.firmware_bucket_name
  description = "Firmware bucket name."
}

output "logs_bucket" {
  value       = module.buckets.logs_bucket_name
  description = "Logs bucket name."
}

output "kms_key_arn" {
  value       = aws_kms_key.s3.arn
  description = "KMS key ARN for bucket encryption."
}
