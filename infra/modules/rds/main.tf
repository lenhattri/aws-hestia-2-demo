locals {
  merged_tags = merge(var.default_tags, {
    Module = "rds"
  })

  deployment_mode          = lower(var.rds_deployment)
  effective_instance_class = var.is_lab ? var.rds_instance_class : var.instance_class
  effective_instance_count = var.is_lab && local.deployment_mode == "single_az" ? 1 : var.instance_count
  proxy_enabled            = var.is_lab ? var.enable_rds_proxy : true
}

resource "random_password" "master" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "master" {
  name                    = "${var.name}/aurora/master"
  recovery_window_in_days = 7
  kms_key_id              = var.secrets_kms_key_arn
  tags                    = local.merged_tags
}

resource "aws_secretsmanager_secret_version" "master" {
  secret_id = aws_secretsmanager_secret.master.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-aurora"
  subnet_ids = var.subnet_ids
  tags       = local.merged_tags
}

resource "aws_security_group" "this" {
  name        = "${var.name}-aurora"
  description = "Aurora security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow from application subnets"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.merged_tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = "${var.name}-aurora"
  engine                          = "aurora-postgresql"
  engine_version                  = var.engine_version
  master_username                 = var.master_username
  master_password                 = random_password.master.result
  database_name                   = var.database_name
  storage_encrypted               = true
  kms_key_id                      = var.storage_kms_key_arn
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  apply_immediately               = var.apply_immediately
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  iam_database_authentication_enabled = true
  copy_tags_to_snapshot           = true
  tags                            = local.merged_tags
}

resource "aws_rds_cluster_instance" "this" {
  count              = local.effective_instance_count
  identifier         = "${var.name}-aurora-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = local.effective_instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.this.name
  tags               = local.merged_tags
}

resource "aws_iam_role" "proxy" {
  count              = local.proxy_enabled ? 1 : 0
  name               = "${var.name}-rds-proxy"
  assume_role_policy = data.aws_iam_policy_document.proxy_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "proxy_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "proxy" {
  count  = local.proxy_enabled ? 1 : 0
  name   = "${var.name}-rds-proxy"
  role   = aws_iam_role.proxy[0].id
  policy = data.aws_iam_policy_document.proxy.json
}

data "aws_iam_policy_document" "proxy" {
  statement {
    actions = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.master.arn]
  }
}

resource "aws_db_proxy" "this" {
  count                 = local.proxy_enabled ? 1 : 0
  name                   = "${var.name}-proxy"
  debug_logging          = true
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.proxy[0].arn
  vpc_security_group_ids = [aws_security_group.this.id]
  vpc_subnet_ids         = var.subnet_ids

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_secretsmanager_secret.master.arn
    iam_auth    = "DISABLED"
  }

  tags = local.merged_tags
}

resource "aws_db_proxy_default_target_group" "this" {
  count         = local.proxy_enabled ? 1 : 0
  db_proxy_name = aws_db_proxy.this[0].name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 80
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "this" {
  count                 = local.proxy_enabled ? 1 : 0
  db_proxy_name         = aws_db_proxy.this[0].name
  target_group_name     = aws_db_proxy_default_target_group.this[0].name
  db_cluster_identifier = aws_rds_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the Aurora cluster."
  value       = aws_rds_cluster.this.arn
}

output "proxy_endpoint" {
  description = "Endpoint of the RDS proxy."
  value       = local.proxy_enabled ? aws_db_proxy.this[0].endpoint : null
}

output "secret_arn" {
  description = "Secrets Manager ARN containing credentials."
  value       = aws_secretsmanager_secret.master.arn
}

output "security_group_id" {
  description = "Security group protecting Aurora."
  value       = aws_security_group.this.id
}
