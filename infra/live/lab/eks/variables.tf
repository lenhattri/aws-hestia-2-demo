variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "lab"
}

variable "cluster_name" {
  type    = string
  default = "lab-eks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "eks_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "eks_node_min" {
  type    = number
  default = 1
}

variable "eks_node_max" {
  type    = number
  default = 2
}

variable "cloudwatch_log_retention_days" {
  type    = number
  default = 3
}

variable "is_lab" {
  type    = bool
  default = true
}
