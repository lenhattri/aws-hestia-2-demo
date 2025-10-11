variable "region" {
  description = "AWS region for the lab environment."
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Environment tag."
  type        = string
  default     = "lab"
}

variable "name_prefix" {
  description = "Prefix applied to network resources."
  type        = string
  default     = "hestia-lab"
}

variable "cidr_block" {
  description = "CIDR block for the lab VPC."
  type        = string
  default     = "10.210.0.0/21"
}

variable "az_count" {
  description = "Number of availability zones to span."
  type        = number
  default     = 1
}

variable "enable_nat_gateway" {
  description = "Toggle NAT gateway creation."
  type        = bool
  default     = true
}

variable "is_lab" {
  description = "Indicates that lab cost-saving defaults should be used."
  type        = bool
  default     = true
}

variable "extra_tags" {
  description = "Additional tags merged into defaults."
  type        = map(string)
  default     = {}
}
