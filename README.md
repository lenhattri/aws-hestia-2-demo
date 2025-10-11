# aws-hestia-system-demo

This repository houses the Terraform reference implementation for the AWS Hestia System demo. The complete infrastructure code, documentation, and automation live under [`infra/`](infra/README.md).

Key features:
- Multi-environment landing zone (`dev`, `stage`, `prod`) with reusable Terraform modules.
- AWS IoT ingestion pipeline spanning IoT Core → Kinesis → DynamoDB → Firehose → S3 → Athena.
- EKS workloads, legacy EC2 fleet, Aurora PostgreSQL, and secured VPC networking.
- GitHub Actions workflow delivering linting, plans, applies, and nightly drift detection.

Refer to the [infrastructure guide](infra/README.md) for detailed architecture, deployment steps, and operational guidance.
