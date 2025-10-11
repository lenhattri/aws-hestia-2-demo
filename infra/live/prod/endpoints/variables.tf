variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "env" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
}

variable "additional_security_group_ids" {
  description = "Additional security groups to attach to interface endpoints."
  type        = list(string)
  default     = []
}
