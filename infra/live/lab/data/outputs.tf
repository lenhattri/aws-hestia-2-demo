output "aurora_cluster_arn" {
  value       = module.aurora.cluster_arn
  description = "ARN of the Aurora cluster."
}

output "aurora_proxy_endpoint" {
  value       = module.aurora.proxy_endpoint
  description = "Aurora proxy endpoint when enabled."
}

output "aurora_secret_arn" {
  value       = module.aurora.secret_arn
  description = "Secret storing Aurora credentials."
}

output "dynamodb_stream_arn" {
  value       = module.telemetry_table.stream_arn
  description = "DynamoDB stream ARN for telemetry table."
}

output "kinesis_firehose_arn" {
  value       = module.telemetry_stream.firehose_arn
  description = "Firehose delivery stream ARN."
}

output "kinesis_stream_arn" {
  value       = null
  description = "Deprecated output retained for compatibility; the lab stack no longer provisions a Kinesis data stream."
}

output "kinesis_firehose_name" {
  value       = module.telemetry_stream.firehose_name
  description = "Name of the telemetry Firehose delivery stream."
}

output "logs_kms_key_arn" {
  value       = data.terraform_remote_state.s3.outputs.kms_key_arn
  description = "Shared KMS key ARN used for lab data encryption."
}

output "data_kms_key_arn" {
  value       = data.terraform_remote_state.s3.outputs.kms_key_arn
  description = "KMS key ARN used for data plane resources."
}

output "secrets_kms_key_arn" {
  value       = data.terraform_remote_state.s3.outputs.kms_key_arn
  description = "KMS key ARN used for secret encryption."
}
