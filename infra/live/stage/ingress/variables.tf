variable "region" {
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "stage"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the ALB."
  type        = string
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
