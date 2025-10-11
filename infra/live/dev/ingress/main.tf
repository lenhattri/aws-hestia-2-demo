data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "dev/vpc/terraform.tfstate"
    region         = var.region
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}

locals {
  tags = merge({
    App       = "aws-hestia-system-demo",
    Env       = var.env,
    Owner     = "platform",
    ManagedBy = "terraform"
  }, var.extra_tags)
}

resource "aws_wafv2_web_acl" "ingress" {
  name        = "${var.env}-shared-alb"
  description = "Baseline protections for shared ingress"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.env}-alb"
    sampled_requests_enabled   = true
  }

  tags = locals.tags
}

module "alb" {
  source = "../../../modules/alb"

  name               = "${var.env}-shared-alb"
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  certificate_arn    = var.certificate_arn
  waf_acl_arn        = aws_wafv2_web_acl.ingress.arn
  default_tags       = locals.tags
}
