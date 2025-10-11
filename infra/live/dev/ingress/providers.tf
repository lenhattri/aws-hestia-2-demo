terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = merge({
      App       = "aws-hestia-system-demo",
      Env       = var.env,
      Owner     = "platform",
      ManagedBy = "terraform"
    }, var.extra_tags)
  }
}
