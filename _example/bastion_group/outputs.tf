output "self_link" {
  description = "Self link of the bastion host"
  value       = module.iap_bastion_group.self_link
}

output "instance_group" {
  description = "Self link of the bastion instance template for use with a MIG"
  value       = module.iap_bastion_group.instance_group
}

output "instance_template" {
  value = module.iap_bastion_group.self_link
}

output "ip_address" {
  description = "Internal IP address of the bastion host"
  value       = module.iap_bastion_group.ip_address
}