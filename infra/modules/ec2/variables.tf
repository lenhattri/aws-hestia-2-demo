variable "name" {
  description = "Prefix for EC2 resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier."
  type        = string
}

variable "bastion_subnet_ids" {
  description = "Subnets hosting the bastion (public)."
  type        = list(string)
}

variable "legacy_subnet_ids" {
  description = "Private subnets for legacy application ASG."
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "Target group ARN for legacy instances."
  type        = string
  default     = ""
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB."
  type        = string
  default     = ""
}

variable "bastion_instance_type" {
  description = "Instance type for the SSM bastion."
  type        = string
  default     = "t3.small"
}

variable "legacy_instance_type" {
  description = "Instance type for legacy application nodes."
  type        = string
  default     = "m6i.large"
}

variable "legacy_ami_id" {
  description = "Override AMI ID for legacy nodes."
  type        = string
  default     = ""
}

variable "legacy_desired_capacity" {
  description = "Desired size of the legacy ASG."
  type        = number
  default     = 3
}

variable "legacy_min_size" {
  description = "Minimum size of the legacy ASG."
  type        = number
  default     = 3
}

variable "legacy_max_size" {
  description = "Maximum size of the legacy ASG."
  type        = number
  default     = 6
}

variable "legacy_app_port" {
  description = "Application port exposed by the legacy service."
  type        = number
  default     = 8080
}

variable "legacy_user_data" {
  description = "User data script for legacy nodes."
  type        = string
  default     = <<-EOT
              #!/bin/bash
              dnf update -y
              systemctl enable --now amazon-ssm-agent
              EOT
}

variable "default_tags" {
  description = "Default tags applied to resources."
  type        = map(string)
  default     = {}
}

variable "is_lab" {
  description = "Flag indicating whether lab-specific sizing applies."
  type        = bool
  default     = false
}

variable "enable_legacy_ec2_asg" {
  description = "Toggle provisioning of the legacy EC2 auto scaling group in lab mode."
  type        = bool
  default     = true
}

variable "enable_ssm_bastion" {
  description = "Toggle provisioning of the SSM bastion in lab mode."
  type        = bool
  default     = false
}
