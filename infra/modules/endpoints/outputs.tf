output "interface_endpoint_ids" {
  description = "Map of interface endpoint IDs."
  value       = { for k, ep in aws_vpc_endpoint.interface : k => ep.id }
}

output "gateway_endpoint_ids" {
  description = "Map of gateway endpoint IDs."
  value       = { for k, ep in aws_vpc_endpoint.gateway : k => ep.id }
}

output "security_group_id" {
  description = "Security group protecting interface endpoints."
  value       = aws_security_group.endpoints.id
}
