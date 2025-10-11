output "bastion_security_group_id" {
  value       = module.compute.bastion_security_group_id
  description = "Security group for the lab bastion host."
}

output "instance_profile_arn" {
  value       = module.compute.instance_profile_arn
  description = "Instance profile ARN for EC2 hosts."
}
