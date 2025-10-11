variable "stream_name" {
  description = "Name of the Kinesis data stream."
  type        = string
}

variable "shard_count" {
  description = "Number of shards in the data stream."
  type        = number
  default     = 2
}

variable "kinesis_shards" {
  description = "Shard count override used in lab mode."
  type        = number
  default     = 2
}

variable "retention_hours" {
  description = "Retention in hours for the stream."
  type        = number
  default     = 72
}

variable "stream_mode" {
  description = "Stream mode (PROVISIONED or ON_DEMAND)."
  type        = string
  default     = "PROVISIONED"
}

variable "kinesis_mode" {
  description = "Stream mode override used in lab deployments."
  type        = string
  default     = "provisioned"
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
}

variable "firehose_bucket_name" {
  description = "S3 bucket receiving Firehose data."
  type        = string
}

variable "firehose_prefix" {
  description = "S3 prefix for Firehose delivery."
  type        = string
  default     = "telemetry/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
}

variable "firehose_log_group_name" {
  description = "CloudWatch log group name for delivery logs."
  type        = string
}

variable "firehose_log_group_arn" {
  description = "ARN of the CloudWatch log group for Firehose."
  type        = string
}

variable "glue_database_name" {
  description = "Glue database name for Athena catalog."
  type        = string
}

variable "glue_table_name" {
  description = "Glue table name backing Athena queries."
  type        = string
}

variable "default_tags" {
  description = "Default tags."
  type        = map(string)
  default     = {}
}

variable "is_lab" {
  description = "Flag indicating whether lab sizing should be applied."
  type        = bool
  default     = false
}
