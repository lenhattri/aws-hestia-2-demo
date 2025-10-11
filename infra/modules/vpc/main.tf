locals {
  merged_tags = merge(var.default_tags, {
    Module = "vpc"
  })
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.merged_tags, {
    Name = "${var.name}-vpc"
  })
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  for_each = var.secondary_cidr_blocks

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.merged_tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? { for subnet in var.public_subnets : subnet.az => subnet if subnet.create_nat } : {}

  vpc = true
  tags = merge(local.merged_tags, {
    Name = "${var.name}-${each.key}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? aws_eip.nat : {}

  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id
  tags = merge(local.merged_tags, {
    Name = "${var.name}-${each.key}-nat"
  })
  depends_on = [aws_internet_gateway.this]
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_log_retention_in_days
  kms_key_id        = var.flow_log_kms_key_arn
  tags              = local.merged_tags
}

resource "aws_iam_role" "flow_logs" {
  name               = "${var.name}-flow-logs-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "flow_logs_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${var.name}-flow-logs-policy"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = ["${aws_cloudwatch_log_group.flow_logs.arn}:*"]
  }
}

resource "aws_flow_log" "this" {
  log_destination      = aws_cloudwatch_log_group.flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.flow_logs.arn
  vpc_id               = aws_vpc.this.id
  tags                 = local.merged_tags
}

resource "aws_subnet" "public" {
  for_each = { for subnet in var.public_subnets : subnet.az => subnet }

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true

  tags = merge(local.merged_tags, {
    Name = "${var.name}-public-${each.key}",
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = { for subnet in var.private_subnets : subnet.az => subnet }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(local.merged_tags, {
    Name = "${var.name}-private-${each.key}",
    Tier = "private"
  })
}

resource "aws_subnet" "isolated" {
  for_each = { for subnet in var.isolated_subnets : subnet.az => subnet }

  vpc_id            = aws_vpc.this.id
  availability_zone = each.value.az
  cidr_block        = each.value.cidr

  tags = merge(local.merged_tags, {
    Name = "${var.name}-isolated-${each.key}",
    Tier = "isolated"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.merged_tags, {
    Name = "${var.name}-public"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id
  tags = merge(local.merged_tags, {
    Name = "${var.name}-private-${each.key}"
  })
}

resource "aws_route" "private_nat" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = try(aws_nat_gateway.this[each.key].id, null)
  lifecycle {
    precondition {
      condition     = var.enable_nat_gateway ? contains(keys(aws_nat_gateway.this), each.key) : true
      error_message = "NAT gateway missing for AZ ${each.key}."
    }
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "isolated" {
  for_each = aws_subnet.isolated

  vpc_id = aws_vpc.this.id
  tags = merge(local.merged_tags, {
    Name = "${var.name}-isolated-${each.key}"
  })
}

resource "aws_route_table_association" "isolated" {
  for_each = aws_subnet.isolated

  subnet_id      = each.value.id
  route_table_id = aws_route_table.isolated[each.key].id
}
