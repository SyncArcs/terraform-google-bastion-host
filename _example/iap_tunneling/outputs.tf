output "service_account" {
  description = "The email for the service account created for the bastion host"
  value       = module.service-account.account_email
}

output "members" {
  description = "members of the iap tunnel instance iam binding"
  value       = module.iap_tunneling.members
}

output "id" {
  description = "id of the iap tunnel instance iam binding"
  value       = module.iap_tunneling.id
}

output "etag" {
  description = "etag of the iap tunnel instance iam binding"
  value       = module.iap_tunneling.etag
}

output "firewall_id" {
  value       = module.iap_tunneling.firewall_id
  description = "Name of the resource. Provided by the client when the resource is created."
}
