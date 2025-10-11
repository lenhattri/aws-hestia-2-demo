# VPC Module

This module provisions the core networking fabric for the aws-hestia-system-demo. It creates a three-tier VPC topology with public, private, and isolated subnets per availability zone. NAT gateways, routing, and flow logging are enabled to support secure ingress/egress and observability.

## Features
- Highly-available VPC spanning the provided AZs
- Public, private, and isolated subnets with tagging and tier metadata
- Optional secondary CIDR associations for expansion
- NAT gateways per AZ (configurable) with elastic IPs
- Flow logs streaming to encrypted CloudWatch Log Groups
- Opinionated tagging aligned with platform standards

## Inputs
Refer to `variables.tf` for the full input specification. At minimum provide:
- `name`
- `cidr_block`
- Subnet definitions (`public_subnets`, `private_subnets`, `isolated_subnets`)
- `flow_log_kms_key_arn`

## Outputs
See `outputs.tf` for the complete list, including subnet maps and the flow log group ARN.

## Usage
```hcl
module "network" {
  source = "../../modules/vpc"

  name       = "demo-dev"
  cidr_block = "10.10.0.0/16"
  public_subnets = [
    { az = "ap-southeast-1a", cidr = "10.10.0.0/20" },
    { az = "ap-southeast-1b", cidr = "10.10.16.0/20" },
    { az = "ap-southeast-1c", cidr = "10.10.32.0/20" }
  ]
  private_subnets = [
    { az = "ap-southeast-1a", cidr = "10.10.48.0/20" },
    { az = "ap-southeast-1b", cidr = "10.10.64.0/20" },
    { az = "ap-southeast-1c", cidr = "10.10.80.0/20" }
  ]
  isolated_subnets = [
    { az = "ap-southeast-1a", cidr = "10.10.96.0/24" },
    { az = "ap-southeast-1b", cidr = "10.10.100.0/24" },
    { az = "ap-southeast-1c", cidr = "10.10.104.0/24" }
  ]
  flow_log_kms_key_arn = var.security_kms_key_arn
  default_tags         = var.default_tags
}
```
