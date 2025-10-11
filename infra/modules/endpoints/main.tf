locals {
  merged_tags = merge(var.default_tags, {
    Module = "vpc-endpoints"
  })

  gateway_endpoints = var.is_lab ? (var.enable_gateway_s3_ddb ? { for k, v in var.gateway_endpoints : k => v if contains(["s3", "dynamodb"], v.service) } : {}) : var.gateway_endpoints

  interface_endpoints = var.enable_interface_vpce ? var.interface_endpoints : {}
}

resource "aws_security_group" "endpoints" {
  name        = "${var.name}-endpoints"
  description = "Security group for interface VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_tags, {
    Name = "${var.name}-endpoints"
  })
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = local.gateway_endpoints

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.value.service}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = each.value.route_table_ids

  tags = merge(local.merged_tags, {
    Name = "${var.name}-${each.key}-endpoint"
  })
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value.service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = length(each.value.subnet_ids) > 0 ? each.value.subnet_ids : var.private_subnet_ids
  private_dns_enabled = each.value.private_dns_enabled
  security_group_ids  = distinct(concat([aws_security_group.endpoints.id], each.value.additional_security_group_ids))

  tags = merge(local.merged_tags, {
    Name = "${var.name}-${each.key}-endpoint"
  })
}
