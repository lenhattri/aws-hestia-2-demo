locals {
  merged_tags = merge(var.default_tags, {
    Module = "iot"
  })
}

resource "aws_iot_thing_type" "this" {
  name = "${var.name}-device"
}

resource "aws_iot_policy" "this" {
  name   = "${var.name}-policy"
  policy = data.aws_iam_policy_document.iot_policy.json
}

data "aws_iam_policy_document" "iot_policy" {
  statement {
    actions = [
      "iot:Connect",
      "iot:Publish",
      "iot:Subscribe",
      "iot:Receive"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "rule" {
  name               = "${var.name}-iot-rule"
  assume_role_policy = data.aws_iam_policy_document.rule_assume.json
  tags               = local.merged_tags
}

data "aws_iam_policy_document" "rule_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "rule" {
  name   = "${var.name}-iot-rule"
  role   = aws_iam_role.rule.id
  policy = data.aws_iam_policy_document.rule.json
}

data "aws_iam_policy_document" "rule" {
  statement {
    actions   = ["kinesis:PutRecord", "kinesis:PutRecords"]
    resources = [var.kinesis_stream_arn]
  }

  statement {
    actions   = ["kms:GenerateDataKey", "kms:Encrypt"]
    resources = [var.kinesis_kms_key_arn]
  }
}

resource "aws_iot_topic_rule" "this" {
  name        = "${var.name}-to-kinesis"
  description = "Route device telemetry into Kinesis"
  enabled     = true
  sql         = var.rule_sql
  sql_version = "2016-03-23"

  kinesis {
    role_arn    = aws_iam_role.rule.arn
    stream_arn  = var.kinesis_stream_arn
    partition_key = "${var.partition_key_template}"
  }
}

resource "aws_iot_provisioning_template" "jitp" {
  name               = "${var.name}-jitp"
  enabled            = true
  provisioning_role_arn = var.provisioning_role_arn
  template_body = jsonencode({
    Parameters = {
      SerialNumber = {
        Type = "String"
      }
    }
    Resources = {
      thing = {
        ThingTypeName = aws_iot_thing_type.this.name
        ThingName     = "${var.name}-\${SerialNumber}"
      }
      certificate = {
        Certificate = {
          CertificateId = "\${certificateId}"
        }
      }
      policy = {
        PolicyName = aws_iot_policy.this.name
      }
    }
  })
  tags = local.merged_tags
}

output "iot_policy_name" {
  description = "Name of the IoT policy attached to devices."
  value       = aws_iot_policy.this.name
}

output "topic_rule_name" {
  description = "Name of the IoT topic rule."
  value       = aws_iot_topic_rule.this.name
}

output "provisioning_template_name" {
  description = "Provisioning template for JITP."
  value       = aws_iot_provisioning_template.jitp.name
}
