variable "name" {
  description = "Prefix for Aurora resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group (isolated)."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitted to connect to Aurora."
  type        = list(string)
}

variable "database_name" {
  description = "Initial database name."
  type        = string
}

variable "master_username" {
  description = "Master username for Aurora."
  type        = string
  default     = "iotadmin"
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version."
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance class for Aurora instances."
  type        = string
  default     = "db.r7g.large"
}

variable "instance_count" {
  description = "Number of Aurora instances to create."
  type        = number
  default     = 2
}

variable "storage_kms_key_arn" {
  description = "KMS key ARN for storage encryption."
  type        = string
}

variable "secrets_kms_key_arn" {
  description = "KMS key ARN for secrets."
  type        = string
}

variable "port" {
  description = "Database port."
  type        = number
  default     = 5432
}

variable "apply_immediately" {
  description = "Apply modifications immediately."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window."
  type        = string
  default     = "04:00-05:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window."
  type        = string
  default     = "sun:06:00-sun:07:00"
}

variable "default_tags" {
  description = "Default tags applied to resources."
  type        = map(string)
  default     = {}
}
