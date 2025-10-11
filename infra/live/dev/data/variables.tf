variable "region" {
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "database_name" {
  type        = string
  default     = "iotdata"
  description = "Initial Aurora database name."
}

variable "aurora_instance_class" {
  type        = string
  default     = "db.r7g.large"
}

variable "aurora_instance_count" {
  type        = number
  default     = 2
}

variable "dynamodb_table_name" {
  type        = string
  default     = "dev-iot-telemetry"
}

variable "stream_name" {
  type        = string
  default     = "dev-iot-telemetry"
}
