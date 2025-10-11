variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS control plane version."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC hosting EKS."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the control plane and worker nodes."
  type        = list(string)
}

variable "service_ipv4_cidr" {
  description = "Kubernetes service CIDR."
  type        = string
  default     = "172.20.0.0/16"
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "secrets_kms_key_arn" {
  description = "KMS key ARN for secrets encryption."
  type        = string
}

variable "log_kms_key_arn" {
  description = "(Deprecated) KMS key ARN for log encryption."
  type        = string
  default     = null
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention period."
  type        = number
  default     = 30
}

variable "cloudwatch_log_retention_days" {
  description = "Alternate log retention period when lab optimisations apply."
  type        = number
  default     = 30
}

variable "node_instance_type" {
  description = "Instance type for worker nodes."
  type        = string
  default     = "m6i.large"
}

variable "eks_instance_type" {
  description = "Instance type override used for lab node groups."
  type        = string
  default     = "t3.medium"
}

variable "node_capacity_type" {
  description = "Capacity type for node group (ON_DEMAND or SPOT)."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_volume_size" {
  description = "Node root volume size in GiB."
  type        = number
  default     = 50
}

variable "node_volume_kms_key_arn" {
  description = "KMS key ARN for node volumes. Leave empty to use AWS managed key."
  type        = string
  default     = ""
}

variable "node_desired_size" {
  description = "Desired node count."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum node count."
  type        = number
  default     = 3
}

variable "eks_node_min" {
  description = "Minimum node count used for lab node groups."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum node count."
  type        = number
  default     = 9
}

variable "eks_node_max" {
  description = "Maximum node count used for lab node groups."
  type        = number
  default     = 4
}

variable "node_ami_id" {
  description = "Optional override AMI ID for worker nodes."
  type        = string
  default     = ""
}

variable "oidc_thumbprint" {
  description = "Thumbprint for the cluster OIDC provider."
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da0afd30df9"
}

variable "irsa_roles" {
  description = "Map of IRSA roles keyed by logical name."
  type = map(object({
    namespace        = string
    service_account  = string
    policy_json      = string
  }))
  default = {
    alb = {
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
      policy_json     = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
    autoscaler = {
      namespace       = "kube-system"
      service_account = "cluster-autoscaler"
      policy_json     = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
    fluentbit = {
      namespace       = "kube-system"
      service_account = "fluent-bit"
      policy_json     = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
  validation {
    condition     = alltrue([for key in ["alb", "autoscaler", "fluentbit"] : contains(keys(var.irsa_roles), key)])
    error_message = "IRSA roles must include alb, autoscaler, and fluentbit entries."
  }
}

variable "region" {
  description = "AWS region for region-specific configurations."
  type        = string
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "is_lab" {
  description = "Flag indicating whether lab sizing should be used."
  type        = bool
  default     = false
}
