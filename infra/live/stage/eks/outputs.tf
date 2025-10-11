output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Private API endpoint."
}

output "node_group_name" {
  value       = module.eks.node_group_name
  description = "Managed node group."
}

output "irsa_roles" {
  value       = module.eks.irsa_role_arns
  description = "Map of IRSA role ARNs."
}
