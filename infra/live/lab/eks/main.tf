data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "lab/vpc/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "lab/data/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

locals {
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    ManagedBy = "terraform"
  }

  irsa_roles = {
    alb = {
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = []
      })
    }
    autoscaler = {
      namespace       = "kube-system"
      service_account = "cluster-autoscaler"
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = []
      })
    }
    fluentbit = {
      namespace       = "kube-system"
      service_account = "fluent-bit"
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = []
      })
    }
  }
}

module "eks" {
  source = "../../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  secrets_kms_key_arn = data.terraform_remote_state.data.outputs.secrets_kms_key_arn
  log_kms_key_arn     = data.terraform_remote_state.data.outputs.data_kms_key_arn
  node_instance_type  = var.eks_instance_type
  node_desired_size   = var.node_desired_size
  node_min_size       = var.eks_node_min
  node_max_size       = var.eks_node_max
  node_capacity_type  = var.node_capacity_type
  region              = var.region
  log_retention_in_days = var.cloudwatch_log_retention_days
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days
  eks_instance_type   = var.eks_instance_type
  eks_node_min        = var.eks_node_min
  eks_node_max        = var.eks_node_max
  is_lab              = var.is_lab
  irsa_roles          = local.irsa_roles
  default_tags        = local.default_tags
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
