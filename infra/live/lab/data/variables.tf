variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "lab"
}

variable "database_name" {
  type        = string
  default     = "labdata"
  description = "Initial Aurora database name."
}

variable "dynamodb_table_name" {
  type        = string
  default     = "lab-iot-telemetry"
}

variable "stream_name" {
  type        = string
  default     = "lab-iot-telemetry"
}

variable "is_lab" {
  type    = bool
  default = true
}

variable "kinesis_mode" {
  type    = string
  default = "provisioned"
}

variable "kinesis_shards" {
  type    = number
  default = 1
}

variable "dynamodb_billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "cloudwatch_log_retention_days" {
  type    = number
  default = 3
}

variable "rds_deployment" {
  type    = string
  default = "single_az"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "enable_rds_proxy" {
  type    = bool
  default = false
}
