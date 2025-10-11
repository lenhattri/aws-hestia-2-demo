# EC2 Module

The EC2 module delivers two key compute primitives: a Session Manager-enabled bastion host and a legacy auto scaling group that can be fronted by the shared ALB. All access is mediated through SSM—no SSH keys are managed.

## Features
- Session Manager bastion deployed across supplied public subnets
- Legacy application ASG with ALB registration and health checks
- Shared IAM instance profile with SSM and CloudWatch logging permissions
- AL2023 Amazon Linux images with optional AMI override
- Hardened metadata options (IMDSv2 enforced)

## Usage
```hcl
module "compute" {
  source = "../../modules/ec2"

  name                  = "demo-dev"
  vpc_id                = module.network.vpc_id
  bastion_subnet_ids    = module.network.public_subnet_ids
  legacy_subnet_ids     = module.network.private_subnet_ids
  alb_target_group_arn  = module.alb.ec2_target_group_arn
  alb_security_group_id = module.alb.security_group_id
  default_tags          = var.default_tags
}
```

Outputs include the security groups and instance profile ARN for downstream policy attachments.
