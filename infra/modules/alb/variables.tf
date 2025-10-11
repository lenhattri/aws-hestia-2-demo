variable "name" {
  description = "Name of the ALB."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ALB."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB placement."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener."
  type        = string
}

variable "waf_acl_arn" {
  description = "WAFv2 Web ACL ARN associated with the ALB."
  type        = string
  default     = ""
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB."
  type        = bool
  default     = true
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "eks_target_port" {
  description = "Port for EKS target group."
  type        = number
  default     = 80
}

variable "eks_health_check_path" {
  description = "Health check path for the EKS target group."
  type        = string
  default     = "/healthz"
}

variable "eks_listener_paths" {
  description = "Paths routed to the EKS target group."
  type        = list(string)
  default     = ["/", "/app/*"]
}

variable "ec2_target_port" {
  description = "Port for EC2 target group."
  type        = number
  default     = 8080
}

variable "ec2_health_check_path" {
  description = "Health check path for EC2 instances."
  type        = string
  default     = "/health"
}

variable "ec2_listener_paths" {
  description = "Paths routed to the EC2 target group."
  type        = list(string)
  default     = ["/legacy/*"]
}

variable "ec2_stickiness_enabled" {
  description = "Enable cookie stickiness for EC2 target group."
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default tags."
  type        = map(string)
  default     = {}
}

variable "is_lab" {
  description = "Flag indicating whether lab optimisations should apply."
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Toggle association of the WAF with the ALB."
  type        = bool
  default     = true
}

variable "enable_legacy_ec2_asg" {
  description = "Control whether legacy EC2 target groups are created."
  type        = bool
  default     = true
}
