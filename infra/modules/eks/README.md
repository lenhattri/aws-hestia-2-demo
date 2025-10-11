# EKS Module

This module provisions an opinionated, private-endpoint Amazon EKS cluster with managed node groups and core operational addons. It is tuned for regulated IoT workloads that require encrypted control planes, IRSA-enabled addons, and cluster observability.

## Features
- Private-only API endpoint with secrets encryption via customer-managed KMS key
- Managed node group with launch template enforcing gp3 volumes and KMS encryption
- Automatic Amazon Linux 2 EKS-optimized AMI resolution
- IRSA roles for AWS Load Balancer Controller, Cluster Autoscaler, and Fluent Bit
- Helm-driven deployment of core addons (ALB controller, metrics-server, autoscaler, Fluent Bit)
- CloudWatch logging and tagging aligned with platform standards

## Inputs
Essential variables are documented in `variables.tf`. Key parameters include:
- `cluster_name`, `kubernetes_version`, `private_subnet_ids`
- `secrets_kms_key_arn`, `log_kms_key_arn`
- Node scaling knobs (`node_desired_size`, `node_min_size`, `node_max_size`)
- Optional overrides for `node_ami_id` and `node_volume_kms_key_arn`

## Outputs
- `cluster_name`, `cluster_endpoint`, `cluster_certificate_authority_data`
- `node_group_name`
- `irsa_role_arns`
- `oidc_provider_arn`

## Usage
```hcl
module "eks" {
  source = "../../modules/eks"

  cluster_name         = "demo-dev"
  kubernetes_version   = "1.29"
  vpc_id               = module.network.vpc_id
  private_subnet_ids   = module.network.private_subnet_ids
  secrets_kms_key_arn  = module.security.eks_secrets_kms_key_arn
  log_kms_key_arn      = module.security.eks_logs_kms_key_arn
  region               = var.region
  default_tags         = var.default_tags
}
```

> **Provider note:** Ensure Helm and Kubernetes providers are configured with the cluster endpoint and credentials exposed by this module before applying Helm releases.
