variable "region" {
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "stage"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.small"
}

variable "legacy_instance_type" {
  type    = string
  default = "m6i.large"
}

variable "legacy_desired_capacity" {
  type    = number
  default = 3
}

variable "legacy_min_size" {
  type    = number
  default = 3
}

variable "legacy_max_size" {
  type    = number
  default = 6
}

variable "iot_rule_sql" {
  type    = string
  default = "SELECT * FROM 'devices/+/telemetry'"
}

variable "iot_partition_key_template" {
  type    = string
  default = "$${topic(2)}"
}

variable "provisioning_role_name" {
  type    = string
  default = "stage-iot-provisioning"
}
