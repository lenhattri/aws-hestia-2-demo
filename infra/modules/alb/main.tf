locals {
  merged_tags = merge(var.default_tags, {
    Module = "alb"
  })

  legacy_enabled = var.is_lab ? var.enable_legacy_ec2_asg : true
  waf_enabled    = var.is_lab ? var.enable_waf : true
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.name}-alb"
  })
}

resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true

  tags = merge(local.merged_tags, {
    Name = var.name
  })
}

resource "aws_lb_target_group" "eks" {
  name     = "${var.name}-eks"
  port     = var.eks_target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = var.eks_health_check_path
    matcher             = "200-399"
    interval            = 30
  }

  tags = merge(local.merged_tags, { Target = "eks" })
}

resource "aws_lb_target_group" "ec2" {
  count       = local.legacy_enabled ? 1 : 0
  name        = "${var.name}-ec2"
  port        = var.ec2_target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = var.ec2_health_check_path
    matcher             = "200-399"
    interval            = 30
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = var.ec2_stickiness_enabled
    cookie_duration = 60
  }

  tags = merge(local.merged_tags, { Target = "ec2" })
}

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks.arn
  }
}

resource "aws_lb_listener" "http" {
  count             = var.certificate_arn == "" ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks.arn
  }
}

resource "aws_lb_listener_rule" "eks" {
  listener_arn = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.eks.arn
  }

  condition {
    path_pattern {
      values = var.eks_listener_paths
    }
  }
}

resource "aws_lb_listener_rule" "ec2" {
  count        = local.legacy_enabled ? 1 : 0
  listener_arn = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2[0].arn
  }

  condition {
    path_pattern {
      values = var.ec2_listener_paths
    }
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  count        = local.waf_enabled && var.waf_acl_arn != "" ? 1 : 0
  resource_arn = aws_lb.this.arn
  web_acl_arn  = var.waf_acl_arn
}

output "alb_arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "eks_target_group_arn" {
  description = "Target group ARN for EKS services."
  value       = aws_lb_target_group.eks.arn
}

output "ec2_target_group_arn" {
  description = "Target group ARN for EC2 services."
  value       = local.legacy_enabled ? aws_lb_target_group.ec2[0].arn : null
}

output "security_group_id" {
  description = "Security group attached to the ALB."
  value       = aws_security_group.alb.id
}
