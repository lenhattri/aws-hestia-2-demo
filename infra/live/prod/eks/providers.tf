terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
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
