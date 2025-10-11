variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

variable "partition_key" {
  description = "Partition key attribute name."
  type        = string
  default     = "deviceId"
}

variable "partition_key_type" {
  description = "Partition key attribute type."
  type        = string
  default     = "S"
}

variable "sort_key" {
  description = "Sort key attribute name."
  type        = string
  default     = "timestamp"
}

variable "sort_key_type" {
  description = "Sort key attribute type."
  type        = string
  default     = "S"
}

variable "ttl_attribute" {
  description = "TTL attribute for expiring telemetry."
  type        = string
  default     = "expiresAt"
}

variable "kms_key_arn" {
  description = "KMS key ARN for server-side encryption."
  type        = string
}

variable "billing_mode" {
  description = "Billing mode (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_billing_mode" {
  description = "Billing mode override for lab deployments."
  type        = string
  default     = "PROVISIONED"
}

variable "table_class" {
  description = "DynamoDB table class."
  type        = string
  default     = "STANDARD"
}

variable "stream_view_type" {
  description = "Stream view type for DynamoDB streams."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "global_secondary_indexes" {
  description = "Optional list of GSI definitions."
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = string
    projection_type = string
    read_capacity   = optional(number)
    write_capacity  = optional(number)
  }))
  default = []
}

variable "default_tags" {
  description = "Default tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "is_lab" {
  description = "Flag indicating whether lab optimisations apply."
  type        = bool
  default     = false
}
