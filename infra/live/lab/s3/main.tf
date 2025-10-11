resource "aws_kms_key" "s3" {
  description             = "${var.env} lab object encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    ManagedBy = "terraform"
    Module    = "kms"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.env}/hestia/lab/s3"
  target_key_id = aws_kms_key.s3.key_id
}

module "buckets" {
  source = "../../../modules/s3"

  env         = var.env
  kms_key_arn = aws_kms_key.s3.arn
  is_lab      = var.is_lab
  default_tags = {
    App       = "aws-hestia-system-demo"
    Env       = var.env
    ManagedBy = "terraform"
  }
}
