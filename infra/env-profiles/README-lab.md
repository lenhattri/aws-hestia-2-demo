# Lab Environment Profile

The **lab** profile provisions an ultra-low-cost clone of the aws-hestia-system-demo platform for short-lived tests (<= 60 minutes). It mirrors the production topology—VPC, endpoints, S3 data lake, data services (Aurora, DynamoDB, Kinesis), EKS, ingress, and compute—while aggressively tuning capacity and retention for minimal spend.

## Usage

```bash
export AWS_REGION=ap-southeast-1
cd infra/live/lab/vpc && terraform init && terraform apply -var-file=../../../env-profiles/terraform.tfvars.lab
./scripts/lab/auto-destroy.sh infra/live/lab/eks
```

Apply other stacks (endpoints, s3, data, ingress, compute) in order as required, always supplying `-var-file=../../../env-profiles/terraform.tfvars.lab`.

To exercise the GitHub Actions automation instead, trigger the `lab-iac` workflow with the desired stack (for example `eks`). The pipeline performs `plan`, awaits manual approval for `apply`, and then destroys the stack automatically after one hour.

## Cost Tips

- Single AZ networking with no NAT gateways; rely on S3/DynamoDB gateway endpoints.
- Only provision ECR interface endpoints when explicitly enabled.
- Short CloudWatch retention (3 days) and 1-shard Kinesis stream.
- DynamoDB on-demand billing, single-AZ `db.t4g.micro` Aurora instance, and RDS proxy disabled.
- Legacy EC2 ASG disabled; keep the lightweight SSM bastion only when testing requires it.
