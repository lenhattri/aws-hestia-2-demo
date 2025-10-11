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
