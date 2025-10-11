variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "lab"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "enable_ssm_bastion" {
  type    = bool
  default = true
}

variable "enable_legacy_ec2_asg" {
  type    = bool
  default = false
}

variable "is_lab" {
  type    = bool
  default = true
}

variable "backend_bucket" {
  type = string
}

variable "backend_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "enable_waf" {
  type    = bool
  default = false
}

variable "eks_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "eks_node_min" {
  type    = number
  default = 1
}

variable "eks_node_max" {
  type    = number
  default = 2
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
