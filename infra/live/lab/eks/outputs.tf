output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Name of the EKS cluster."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint URL for the EKS API server."
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "CA data for authenticating with the cluster."
}
