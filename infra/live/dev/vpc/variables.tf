variable "region" {
  description = "AWS region for deployment."
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefix applied to network resources."
  type        = string
}

variable "cidr_block" {
  description = "Primary CIDR block for the VPC."
  type        = string
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

variable "flow_log_kms_key_arn" {
  description = "KMS key for VPC flow log encryption."
  type        = string
}

variable "extra_tags" {
  description = "Additional tags to merge into defaults."
  type        = map(string)
  default     = {}
}
