data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "stage/vpc/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "stage/data/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

locals {
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    Owner     = "platform"
    ManagedBy = "terraform"
  }

  irsa_roles = {
    alb = {
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = [
              "elasticloadbalancing:*",
              "ec2:Describe*",
              "iam:CreateServiceLinkedRole",
              "cognito-idp:DescribeUserPoolClient",
              "acm:ListCertificates",
              "waf-regional:GetWebACL",
              "waf-regional:AssociateWebACL",
              "wafv2:GetWebACL",
              "wafv2:AssociateWebACL"
            ]
            Resource = "*"
          }
        ]
      })
    }
    autoscaler = {
      namespace       = "kube-system"
      service_account = "cluster-autoscaler"
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = [
              "autoscaling:DescribeAutoScalingGroups",
              "autoscaling:DescribeAutoScalingInstances",
              "autoscaling:DescribeTags",
              "autoscaling:SetDesiredCapacity",
              "autoscaling:TerminateInstanceInAutoScalingGroup",
              "ec2:DescribeLaunchTemplateVersions"
            ]
            Resource = "*"
          }
        ]
      })
    }
    fluentbit = {
      namespace       = "kube-system"
      service_account = "fluent-bit"
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = [
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams",
              "logs:DescribeLogGroups"
            ]
            Resource = "*"
          }
        ]
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
  node_instance_type  = var.node_instance_type
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_capacity_type  = var.node_capacity_type
  node_volume_kms_key_arn = data.terraform_remote_state.data.outputs.data_kms_key_arn
  region              = var.region
  irsa_roles          = local.irsa_roles
  default_tags        = local.default_tags
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
