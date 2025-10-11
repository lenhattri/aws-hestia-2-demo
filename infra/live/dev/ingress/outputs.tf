output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name for the shared ALB."
}

output "eks_target_group_arn" {
  value       = module.alb.eks_target_group_arn
  description = "Target group ARN for EKS ingress."
}

output "ec2_target_group_arn" {
  value       = module.alb.ec2_target_group_arn
  description = "Target group ARN for legacy EC2 services."
}

output "alb_security_group_id" {
  value       = module.alb.security_group_id
  description = "Security group ID attached to the ALB."
}
