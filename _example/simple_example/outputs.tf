output "service_account" {
  description = "The email for the service account created for the bastion host"
  value       = module.iap_bastion.service_account
}

output "hostname" {
  description = "Host name of the bastion"
  value       = module.iap_bastion.hostname
}

output "ip_address" {
  description = "Internal IP address of the bastion host"
  value       = module.iap_bastion.ip_address
}

output "self_link" {
  description = "Self link of the bastion host"
  value       = module.iap_bastion.self_link
}

output "instance_template" {
  description = "Self link of the bastion instance template for use with a MIG"
  value       = module.iap_bastion.instance_template
}