output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ARN of the lab application load balancer."
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the lab ALB."
}

output "eks_target_group_arn" {
  value       = module.alb.eks_target_group_arn
  description = "Target group ARN for EKS services."
}

output "alb_security_group_id" {
  value       = module.alb.security_group_id
  description = "Security group protecting the ALB."
}
