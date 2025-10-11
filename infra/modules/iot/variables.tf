variable "name" {
  description = "Prefix for IoT resources."
  type        = string
}

variable "kinesis_stream_arn" {
  description = "ARN of the Kinesis stream to receive telemetry."
  type        = string
}

variable "kinesis_kms_key_arn" {
  description = "KMS key used by the Kinesis stream."
  type        = string
}

variable "rule_sql" {
  description = "SQL statement for the IoT topic rule."
  type        = string
  default     = "SELECT * FROM 'devices/+/telemetry'"
}

variable "partition_key_template" {
  description = "Partition key template for Kinesis action."
  type        = string
  default     = "$${topic(2)}"
}

variable "provisioning_role_arn" {
  description = "IAM role ARN that provisions devices (JITP)."
  type        = string
}

variable "default_tags" {
  description = "Default tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "is_lab" {
  description = "Flag indicating whether to apply lab-oriented defaults."
  type        = bool
  default     = false
}
