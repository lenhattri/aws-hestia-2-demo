locals {
  merged_tags = merge(var.default_tags, {
    Module = "ec2"
  })

  bastion_enabled = var.is_lab ? var.enable_ssm_bastion : true
  legacy_enabled  = var.is_lab ? var.enable_legacy_ec2_asg : true
}

data "aws_ssm_parameter" "linux_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  resolved_ami_id = var.legacy_ami_id != "" ? var.legacy_ami_id : data.aws_ssm_parameter.linux_ami.value
}

resource "aws_security_group" "bastion" {
  count       = local.bastion_enabled ? 1 : 0
  name        = "${var.name}-bastion"
  description = "SSM bastion security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.name}-bastion"
  })
}

resource "aws_security_group" "legacy" {
  count       = local.legacy_enabled ? 1 : 0
  name        = "${var.name}-legacy"
  description = "Legacy compute security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "ALB ingress"
    from_port   = var.legacy_app_port
    to_port     = var.legacy_app_port
    protocol    = "tcp"
    security_groups = var.alb_security_group_id != "" ? [var.alb_security_group_id] : []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.name}-legacy"
  })
}

resource "aws_iam_role" "instance" {
  name               = "${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.instance_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "instance" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ])

  role       = aws_iam_role.instance.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance.name
}

resource "aws_launch_template" "bastion" {
  count         = local.bastion_enabled ? 1 : 0
  name_prefix   = "${var.name}-bastion-"
  image_id      = local.resolved_ami_id
  instance_type = var.bastion_instance_type
  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }
  metadata_options {
    http_tokens = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.merged_tags, { Role = "bastion" })
  }
}

resource "aws_autoscaling_group" "bastion" {
  count                     = local.bastion_enabled ? 1 : 0
  name                      = "${var.name}-bastion"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.bastion_subnet_ids
  health_check_type         = "EC2"
  launch_template {
    id      = aws_launch_template.bastion[0].id
    version = aws_launch_template.bastion[0].latest_version
  }
  enabled_metrics = ["GroupInServiceInstances", "GroupDesiredCapacity"]

  tag {
    key                 = "Name"
    value               = "${var.name}-bastion"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "legacy" {
  count         = local.legacy_enabled ? 1 : 0
  name_prefix   = "${var.name}-legacy-"
  image_id      = local.resolved_ami_id
  instance_type = var.legacy_instance_type
  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }
  vpc_security_group_ids = local.legacy_enabled ? [aws_security_group.legacy[0].id] : []
  metadata_options {
    http_tokens = "required"
  }
  user_data = base64encode(var.legacy_user_data)
  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.merged_tags, { Role = "legacy" })
  }
}

resource "aws_autoscaling_group" "legacy" {
  count               = local.legacy_enabled ? 1 : 0
  name                = "${var.name}-legacy"
  max_size            = var.legacy_max_size
  min_size            = var.legacy_min_size
  desired_capacity    = var.legacy_desired_capacity
  vpc_zone_identifier = var.legacy_subnet_ids
  health_check_type   = "ELB"
  target_group_arns   = var.alb_target_group_arn != "" ? [var.alb_target_group_arn] : []

  launch_template {
    id      = aws_launch_template.legacy[0].id
    version = aws_launch_template.legacy[0].latest_version
  }

  enabled_metrics = ["GroupInServiceInstances", "GroupDesiredCapacity"]

  tag {
    key                 = "Name"
    value               = "${var.name}-legacy"
    propagate_at_launch = true
  }
}

output "bastion_security_group_id" {
  description = "Security group for the bastion hosts."
  value       = local.bastion_enabled ? aws_security_group.bastion[0].id : null
}

output "legacy_security_group_id" {
  description = "Security group for legacy application instances."
  value       = local.legacy_enabled ? aws_security_group.legacy[0].id : null
}

output "instance_profile_arn" {
  description = "Instance profile ARN used by EC2 instances."
  value       = aws_iam_instance_profile.this.arn
}
