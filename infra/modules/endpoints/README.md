# VPC Endpoints Module

Creates gateway and interface VPC endpoints to keep AWS service traffic within the aws-hestia-system-demo network perimeter. The module provisions a dedicated security group and allows per-service configuration.

## Features
- Gateway endpoints for S3 and DynamoDB with configurable route table attachments
- Interface endpoints with managed security group and optional per-endpoint subnet overrides
- Tag propagation aligned with platform defaults

## Inputs
Key inputs include:
- `vpc_id`, `vpc_cidr_block`, `private_subnet_ids`
- `gateway_endpoints` map for services such as S3, DynamoDB
- `interface_endpoints` map for interface services (STS, ECR, CloudWatch Logs, Secrets Manager, SSM)

## Outputs
- `interface_endpoint_ids`
- `gateway_endpoint_ids`
- `security_group_id`

## Usage
```hcl
module "endpoints" {
  source = "../../modules/endpoints"

  name               = "demo-dev"
  region             = var.region
  vpc_id             = module.network.vpc_id
  vpc_cidr_block     = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids

  gateway_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = [for _, rt in module.network.private_subnet_map : rt]
    }
  }

  interface_endpoints = {
    sts = { service = "sts" }
    secretsmanager = { service = "secretsmanager" }
  }

  default_tags = var.default_tags
}
```
