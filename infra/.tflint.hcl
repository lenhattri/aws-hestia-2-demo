config {
  terraform_version = "1.9.0"
}

plugin "aws" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_s3_bucket_public_read_prohibited" {
  enabled = true
}

rule "aws_s3_bucket_public_write_prohibited" {
  enabled = true
}
