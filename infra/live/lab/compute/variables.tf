variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "lab"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "enable_ssm_bastion" {
  type    = bool
  default = true
}

variable "enable_legacy_ec2_asg" {
  type    = bool
  default = false
}

variable "is_lab" {
  type    = bool
  default = true
}
