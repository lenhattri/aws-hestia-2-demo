# RDS Module

Provisions an Aurora PostgreSQL cluster with multi-AZ instances, encrypted storage, and an IAM-authenticated RDS Proxy. Secrets are generated and rotated via AWS Secrets Manager.

## Features
- Customer-managed KMS encryption for storage and Secrets Manager
- Auto-generated credentials stored securely in Secrets Manager
- Configurable maintenance and backup windows
- RDS Proxy for connection pooling and failover resilience
- Security group with CIDR allow list for application traffic

## Usage
```hcl
module "aurora" {
  source = "../../modules/rds"

  name                  = "demo-dev"
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.isolated_subnet_ids
  allowed_cidr_blocks   = [module.network.vpc_cidr_block]
  database_name         = "iotdata"
  storage_kms_key_arn   = aws_kms_key.data.arn
  secrets_kms_key_arn   = aws_kms_key.secrets.arn
  default_tags          = var.default_tags
}
```

Outputs expose the Aurora cluster ARN, proxy endpoint, secrets ARN, and security group ID.
