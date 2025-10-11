locals {
  merged_tags = merge(var.default_tags, {
    Module = "s3"
  })

  versioning_status       = var.is_lab ? "Suspended" : "Enabled"
  telemetry_transition_1  = var.is_lab ? 30 : 90
  telemetry_transition_2  = var.is_lab ? 60 : 180
  logs_expiration_in_days = var.is_lab ? 30 : 365
}

locals {
  buckets = {
    telemetry = {
      purpose = "telemetry"
      name    = "${var.env}-aws-hestia-system-demo-telemetry"
    }
    firmware = {
      purpose = "firmware"
      name    = "${var.env}-aws-hestia-system-demo-firmware"
    }
    logs = {
      purpose = "logs"
      name    = "${var.env}-aws-hestia-system-demo-logs"
    }
  }
}

resource "aws_s3_bucket" "this" {
  for_each      = local.buckets
  bucket        = each.value.name
  force_destroy = false
  tags = merge(local.merged_tags, {
    Purpose = each.value.purpose
  })
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  versioning_configuration {
    status = local.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "telemetry" {
  bucket = aws_s3_bucket.this["telemetry"].id

  rule {
    id     = "tiered-storage"
    status = "Enabled"

    transition {
      days          = local.telemetry_transition_1
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = local.telemetry_transition_2
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.this["logs"].id

  rule {
    id     = "log-retention"
    status = "Enabled"

    expiration {
      days = local.logs_expiration_in_days
    }
  }
}

resource "aws_s3_bucket_policy" "secure_transport" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id
  policy = data.aws_iam_policy_document.secure_transport[each.key].json
}

data "aws_iam_policy_document" "secure_transport" {
  for_each = aws_s3_bucket.this

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [each.value.arn, "${each.value.arn}/*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

output "telemetry_bucket_name" {
  description = "Telemetry data lake bucket name."
  value       = aws_s3_bucket.this["telemetry"].bucket
}

output "firmware_bucket_name" {
  description = "Firmware distribution bucket name."
  value       = aws_s3_bucket.this["firmware"].bucket
}

output "logs_bucket_name" {
  description = "Centralized logs bucket name."
  value       = aws_s3_bucket.this["logs"].bucket
}
