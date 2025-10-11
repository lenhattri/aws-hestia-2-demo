terraform {
  required_version = ">= 1.9.0"
  backend "s3" {
    bucket         = "aws-hestia-system-demo-tfstate"
    key            = "prod/data/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "aws-hestia-system-demo-tf-locks"
    encrypt        = true
  }
}
