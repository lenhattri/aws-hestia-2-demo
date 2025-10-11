output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the provisioned VPC."
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet identifiers."
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet identifiers."
}

output "isolated_subnet_ids" {
  value       = module.vpc.isolated_subnet_ids
  description = "Isolated subnet identifiers."
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "CIDR block assigned to the VPC."
}
