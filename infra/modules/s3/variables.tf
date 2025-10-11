variable "env" {
  description = "Environment identifier used for bucket naming."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used for bucket encryption."
  type        = string
}

variable "default_tags" {
  description = "Default tags applied to buckets."
  type        = map(string)
  default     = {}
}
