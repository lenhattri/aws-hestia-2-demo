variable "region" {
  type        = string
  default     = "ap-southeast-1"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "cluster_name" {
  type    = string
  default = "prod-eks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "node_instance_type" {
  type    = string
  default = "m6i.large"
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 3
}

variable "node_max_size" {
  type    = number
  default = 6
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}
