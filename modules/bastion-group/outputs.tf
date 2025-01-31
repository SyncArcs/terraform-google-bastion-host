output "self_link" {
  description = "Name of the bastion MIG"
  value       = module.mig.self_link
}

output "instance_group" {
  description = "Instance-group url of managed instance group"
  value       = module.mig.instance_group
}

output "ip_address" {
  description = "Internal IP address of the bastion host"
  value       = module.instance_template.ip_address
}