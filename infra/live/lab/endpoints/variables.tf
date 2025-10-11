variable "region" {
  description = "AWS region for endpoint deployment."
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Environment label."
  type        = string
  default     = "lab"
}

variable "additional_security_group_ids" {
  description = "Additional security groups attached to interface endpoints."
  type        = list(string)
  default     = []
}

variable "enable_interface_vpce" {
  description = "Enable interface VPC endpoints."
  type        = bool
  default     = true
}

variable "enable_gateway_s3_ddb" {
  description = "Enable S3/DynamoDB gateway endpoints."
  type        = bool
  default     = true
}

variable "is_lab" {
  description = "Indicates that the lab footprint should be used."
  type        = bool
  default     = true
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

variable "enable_ssm_bastion" {
  type    = bool
  default = true
}

variable "enable_legacy_ec2_asg" {
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
