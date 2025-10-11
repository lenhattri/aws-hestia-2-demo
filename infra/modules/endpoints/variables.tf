variable "name" {
  description = "Prefix used for endpoint resources."
  type        = string
}

variable "vpc_id" {
  description = "Target VPC identifier."
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR used for security group rules."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used for default interface endpoint placement."
  type        = list(string)
}

variable "region" {
  description = "AWS region for endpoint service names."
  type        = string
}

variable "gateway_endpoints" {
  description = "Map of gateway endpoint definitions keyed by logical name."
  type = map(object({
    service         = string
    route_table_ids = list(string)
  }))
  default = {}
}

variable "interface_endpoints" {
  description = "Map of interface endpoint definitions keyed by logical name."
  type = map(object({
    service                         = string
    subnet_ids                      = optional(list(string), [])
    private_dns_enabled             = optional(bool, true)
    additional_security_group_ids   = optional(list(string), [])
  }))
  default = {}
}

variable "is_lab" {
  description = "Flag indicating whether the lab footprint should be used."
  type        = bool
  default     = false
}

variable "enable_interface_vpce" {
  description = "Toggle creation of interface VPC endpoints."
  type        = bool
  default     = true
}

variable "enable_gateway_s3_ddb" {
  description = "Toggle creation of S3/DynamoDB gateway endpoints in lab mode."
  type        = bool
  default     = false
}

variable "default_tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
