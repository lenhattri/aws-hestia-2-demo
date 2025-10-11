output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Private EKS API server endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded cluster CA bundle."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_name" {
  description = "Managed node group name."
  value       = aws_eks_node_group.this.node_group_name
}

output "irsa_role_arns" {
  description = "Map of IRSA role ARNs."
  value       = { for k, role in aws_iam_role.irsa : k => role.arn }
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA."
  value       = aws_iam_openid_connect_provider.this.arn
}
