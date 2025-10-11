# IoT Core Module

Provisions the IoT control plane components that ingest device telemetry and push it into the Kinesis stream. Includes Just-in-Time Provisioning (JITP) templates so that new devices can self-provision securely.

## Features
- Thing type and device policy managed as code
- IoT topic rule routing to Kinesis with per-message partition keys
- IAM role scoped for the topic rule and KMS usage
- JITP provisioning template referencing the managed policy and thing type

## Usage
```hcl
module "iot" {
  source = "../../modules/iot"

  name                   = "demo-dev"
  kinesis_stream_arn     = module.telemetry_stream.stream_arn
  kinesis_kms_key_arn    = aws_kms_key.data.arn
  provisioning_role_arn  = aws_iam_role.iot_provisioning.arn
  default_tags           = var.default_tags
}
```

Outputs return the policy name, topic rule name, and provisioning template name for operational visibility.
