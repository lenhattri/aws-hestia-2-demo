variable "name" {
  description = "Prefix for VPC related resources."
  type        = string
}

variable "cidr_block" {
  description = "Primary CIDR block for the VPC."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "cidr_block must be a valid IPv4 CIDR."
  }
}

variable "secondary_cidr_blocks" {
  description = "Optional map of secondary CIDR block associations."
  type        = map(string)
  default     = {}
}

variable "public_subnets" {
  description = "List of public subnet definitions."
  type = list(object({
    az         = string
    cidr       = string
    create_nat = optional(bool, true)
  }))
}

variable "private_subnets" {
  description = "List of private subnet definitions."
  type = list(object({
    az   = string
    cidr = string
  }))
}

variable "isolated_subnets" {
  description = "List of isolated subnet definitions."
  type = list(object({
    az   = string
    cidr = string
  }))
}

variable "enable_nat_gateway" {
  description = "Whether to provision NAT gateways."
  type        = bool
  default     = true
}

variable "is_lab" {
  description = "Flag indicating whether the deployment targets the lab environment."
  type        = bool
  default     = false
}

variable "az_count" {
  description = "Number of availability zones to target."
  type        = number
  default     = 3
}

variable "flow_log_retention_in_days" {
  description = "Retention for VPC flow logs."
  type        = number
  default     = 30
}

variable "cloudwatch_log_retention_days" {
  description = "Alternate retention period used when lab optimisations are enabled."
  type        = number
  default     = 30
}

variable "flow_log_kms_key_arn" {
  description = "KMS key ARN for flow log encryption."
  type        = string
  default     = null
}

variable "default_tags" {
  description = "Map of tags to apply to resources."
  type        = map(string)
  default     = {}
}
