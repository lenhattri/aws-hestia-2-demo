output "vpc_id" {
  description = "Identifier of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = [for s in aws_subnet.private : s.id]
}

output "isolated_subnet_ids" {
  description = "List of isolated subnet IDs."
  value       = [for s in aws_subnet.isolated : s.id]
}

output "public_subnet_map" {
  description = "Map of AZ to public subnet IDs."
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "private_subnet_map" {
  description = "Map of AZ to private subnet IDs."
  value       = { for k, s in aws_subnet.private : k => s.id }
}

output "isolated_subnet_map" {
  description = "Map of AZ to isolated subnet IDs."
  value       = { for k, s in aws_subnet.isolated : k => s.id }
}

output "vpc_cidr_block" {
  description = "Primary VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "flow_log_group_arn" {
  description = "ARN of the VPC flow log group."
  value       = aws_cloudwatch_log_group.flow_logs.arn
}

output "public_route_table_id" {
  description = "Route table ID for public subnets."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Map of AZ to private route table IDs."
  value       = { for k, rt in aws_route_table.private : k => rt.id }
}

output "isolated_route_table_ids" {
  description = "Map of AZ to isolated route table IDs."
  value       = { for k, rt in aws_route_table.isolated : k => rt.id }
}
