output "members" {
  description = "members of the iap tunnel instance iam binding"
  value = {
    for key, instance in google_iap_tunnel_instance_iam_binding.enable_iap :
    key => instance.members
  }
}

output "id" {
  description = "id of the iap tunnel instance iam binding"
  value = {
    for key, instance in google_iap_tunnel_instance_iam_binding.enable_iap :
    key => instance.id
  }
}

output "etag" {
  description = "etag of the iap tunnel instance iam binding"
  value = {
    for key, instance in google_iap_tunnel_instance_iam_binding.enable_iap :
    key => instance.etag
  }
}

output "firewall_id" {
  value       = join("", google_compute_firewall.allow_from_iap_to_instances[*].id)
  description = "Name of the resource. Provided by the client when the resource is created."
}

output "name" {
  value       = join("", google_compute_firewall.allow_from_iap_to_instances[*].name)
  description = "an identifier for the resource with format"
}

output "firewall_creation_timestamp" {
  value       = join("", google_compute_firewall.allow_from_iap_to_instances[*].creation_timestamp)
  description = "Creation timestamp in RFC3339 text format."
}

output "firewall_self_link" {
  value       = join("", google_compute_firewall.allow_from_iap_to_instances[*].self_link)
  description = "The URI of the created resource."
}
