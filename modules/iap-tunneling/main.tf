module "labels" {
  source      = "git::https://github.com/SyncArcs/terraform-google-labels.git?ref=v1.0.0"
  name        = var.name
  environment = var.environment
  label_order = var.label_order
  managedby   = var.managedby
  repository  = var.repository
}

data "google_client_config" "current" {
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allow_from_iap_to_instances" {
  count   = var.create_firewall_rule ? 1 : 0
  project = data.google_client_config.current.project != "" ? data.google_client_config.current.project : data.google_client_config.current.project
  name    = format("%s-%s", module.labels.id, (count.index))
  network = var.network


  allow {
    protocol = "tcp"
    ports    = toset(concat(["22"], var.additional_ports))
  }
  source_ranges = ["0.0.0.0/0"]

  target_service_accounts = length(var.service_accounts) > 0 ? var.service_accounts : null
  target_tags             = length(var.network_tags) > 0 ? var.network_tags : null
}

resource "google_iap_tunnel_instance_iam_binding" "enable_iap" {
  for_each = {
    for i in var.instances :
    "${i.name} ${i.zone}" => i
  }
  project  = data.google_client_config.current.project
  zone     = each.value.zone
  instance = each.value.name
  role     = "roles/iap.tunnelResourceAccessor"
  members  = var.members
}