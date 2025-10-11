locals {
  merged_tags = merge(var.default_tags, {
    Module = "dynamodb"
  })

  billing_mode = var.is_lab ? upper(var.dynamodb_billing_mode) : var.billing_mode
}

resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = local.billing_mode
  hash_key       = var.partition_key
  range_key      = var.sort_key
  stream_enabled = true
  stream_view_type = var.stream_view_type
  table_class    = var.table_class

  attribute {
    name = var.partition_key
    type = var.partition_key_type
  }

  attribute {
    name = var.sort_key
    type = var.sort_key_type
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type
      read_capacity   = try(global_secondary_index.value.read_capacity, null)
      write_capacity  = try(global_secondary_index.value.write_capacity, null)
    }
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = true
  }

  tags = local.merged_tags
}

output "table_name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.this.name
}

output "stream_arn" {
  description = "ARN of the DynamoDB stream."
  value       = aws_dynamodb_table.this.stream_arn
}
