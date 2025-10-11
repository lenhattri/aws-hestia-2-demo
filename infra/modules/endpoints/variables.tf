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

variable "default_tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
