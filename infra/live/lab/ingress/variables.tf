variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "lab"
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "ingress_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "enable_waf" {
  type    = bool
  default = false
}

variable "enable_legacy_ec2_asg" {
  type    = bool
  default = false
}

variable "is_lab" {
  type    = bool
  default = true
}
