output "bastion_security_group_id" {
  value       = module.compute.bastion_security_group_id
  description = "Security group protecting bastion hosts."
}

output "legacy_security_group_id" {
  value       = module.compute.legacy_security_group_id
  description = "Security group for legacy application servers."
}

output "instance_profile_arn" {
  value       = module.compute.instance_profile_arn
  description = "IAM instance profile ARN used by EC2 instances."
}

output "iot_policy_name" {
  value       = module.iot.iot_policy_name
  description = "IoT policy name for device connectivity."
}

output "iot_topic_rule" {
  value       = module.iot.topic_rule_name
  description = "IoT rule directing telemetry into Kinesis."
}

output "iot_provisioning_template" {
  value       = module.iot.provisioning_template_name
  description = "Provisioning template enabling JITP."
}
