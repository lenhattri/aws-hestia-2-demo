output "interface_endpoint_ids" {
  value       = module.endpoints.interface_endpoint_ids
  description = "Interface endpoints provisioned in the VPC."
}

output "gateway_endpoint_ids" {
  value       = module.endpoints.gateway_endpoint_ids
  description = "Gateway endpoint identifiers."
}

output "endpoint_security_group_id" {
  value       = module.endpoints.security_group_id
  description = "Security group associated with endpoints."
}
