variable "region" {
  description = "AWS region for S3 resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  description = "Environment tag."
  type        = string
  default     = "lab"
}

variable "is_lab" {
  description = "Enable lab optimisations."
  type        = bool
  default     = true
}
