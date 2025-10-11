# ALB Module

This module provisions an internet-facing Application Load Balancer that fronts both the EKS workloads and the legacy EC2 fleet. HTTPS is enforced with an ACM certificate and the load balancer is protected by AWS WAF.

## Features
- Dedicated security group with configurable CIDR allow list
- Dual target groups (IP mode for EKS, instance mode for EC2)
- Listener rules to route paths to modern (EKS) versus legacy (EC2) services
- AWS WAF association and TLS 1.3 policy baseline
- Cookie stickiness enabled for the EC2 target group to preserve session state

## Usage
```hcl
module "alb" {
  source = "../../modules/alb"

  name               = "demo-shared-alb"
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  certificate_arn    = aws_acm_certificate.shared.arn
  waf_acl_arn        = aws_wafv2_web_acl.shared.arn
  default_tags       = var.default_tags
}
```

Outputs expose the ALB DNS name and target group ARNs for downstream registrations.
