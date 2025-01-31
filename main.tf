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
resource "random_id" "random_role_id_suffix" {
  byte_length = 2
}

locals {
  base_role_id          = "osLoginProjectGet"
  service_account_email = var.service_account_email == "" ? try(google_service_account.bastion_host[0].email, "") : var.service_account_email
  service_account_roles = var.service_account_email == "" ? toset(compact(concat(
    var.service_account_roles,
    var.service_account_roles_supplemental,
  ))) : []
  temp_role_id = var.random_role_id ? format(
    "%s_%s",
    local.base_role_id,
    random_id.random_role_id_suffix.hex,
  ) : local.base_role_id
}

resource "google_service_account" "bastion_host" {
  count        = var.service_account_email == "" ? 1 : 0
  project      = data.google_client_config.current.project
  account_id   = var.service_account_name
  display_name = "Service Account for Bastion"
}

######==============================================================================
###### instance_template module call.
######==============================================================================
module "instance_template" {
  source               = "git::https://github.com/SyncArcs/terraform-google-template-instance.git?ref=v1.0.0"
  instance_template    = true
  name                 = format("%s", module.labels.id)
  region               = var.region
  source_image_family  = var.image_family
  source_image_project = var.image_project
  disk_size_gb         = var.disk_size_gb
  subnetwork           = var.subnet
  service_account      = null
  metadata = {
    ssh-keys = var.ssh-keys
  }
  ## public IP if enable_public_ip is true
  enable_public_ip = true
}

#####==============================================================================
##### Manages a VM instance resource within GCE.
#####==============================================================================
resource "google_compute_instance_from_template" "bastion_vm" {
  count   = var.create_instance_from_template ? 1 : 0
  name    = format("%s", module.labels.id)
  project = data.google_client_config.current.project
  zone    = var.zone
  labels  = var.labels

  network_interface {
    subnetwork         = var.subnet
    subnetwork_project = data.google_client_config.current.project != "" ? data.google_client_config.current.project : data.google_client_config.current.project
    #    access_config      =  var.access_config
  }
  source_instance_template = module.instance_template.self_link_unique
}

module "iap_tunneling" {
  source               = "./modules/iap-tunneling"
  additional_ports     = var.additional_ports
  network              = var.network
  members              = var.members
  create_firewall_rule = var.create_firewall_rule
  service_accounts     = [local.service_account_email]
  instances = var.create_instance_from_template ? [{
    name = try(google_compute_instance_from_template.bastion_vm[0].name, "")
    zone = var.zone
  }] : []

}

resource "google_service_account_iam_binding" "bastion_sa_user" {
  count              = var.service_account_email == "" ? 1 : 0
  service_account_id = google_service_account.bastion_host[0].id
  role               = "roles/iam.serviceAccountUser"
  members            = var.members
}

resource "google_project_iam_member" "bastion_sa_bindings" {
  for_each = local.service_account_roles
  project  = data.google_client_config.current.project
  role     = each.key
  member   = "serviceAccount:${local.service_account_email}"
}

resource "google_project_iam_custom_role" "compute_os_login_viewer" {
  count       = var.service_account_email == "" ? 1 : 0
  project     = data.google_client_config.current.project
  role_id     = local.temp_role_id
  title       = "OS Login Project Get Role"
  description = "From Terraform: iap-bastion module custom role for more fine grained scoping of permissions"
  permissions = ["compute.projects.get"]
}

resource "google_project_iam_member" "bastion_oslogin_bindings" {
  count   = var.service_account_email == "" ? 1 : 0
  project = data.google_client_config.current.project
  role    = "projects/${data.google_client_config.current.project}/roles/${google_project_iam_custom_role.compute_os_login_viewer[0].role_id}"
  member  = "serviceAccount:${local.service_account_email}"
}
