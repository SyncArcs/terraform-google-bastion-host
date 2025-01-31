provider "google" {
  project = "soy-smile-435017-c5"
  region  = "us-west1"
  zone    = "us-west1-a"
}

#####==============================================================================
##### vpc module call.
#####==============================================================================
module "vpc" {
  source                                    = "git::https://github.com/SyncArcs/terraform-google-vpc.git?ref=v1.0.1"
  name                                      = "app"
  environment                               = "test"
  routing_mode                              = "REGIONAL"
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
}

#####==============================================================================
##### subnet module call.
#####==============================================================================
module "subnet" {
  source        = "git::https://github.com/SyncArcs/terraform-google-subnet.git?ref=v1.0.0"
  name          = "app"
  environment   = "test"
  subnet_names  = ["subnet-a"]
  gcp_region    = "us-west1"
  network       = module.vpc.vpc_id
  ip_cidr_range = ["10.10.1.0/24"]
}

#####==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source      = "git::https://github.com/SyncArcs/terraform-google-firewall.git?ref=v1.0.0"
  name        = "app"
  environment = "test"
  network     = module.vpc.vpc_id

  ingress_rules = [
    {
      name          = "allow-tcp-http-ingress"
      description   = "Allow TCP, HTTP ingress traffic"
      direction     = "INGRESS"
      priority      = 1000
      source_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "80"]
        }
      ]
    }
  ]
}

#####==============================================================================
##### service-account module call .
#####==============================================================================
module "service-account" {
  source = "git::https://github.com/SyncArcs/terraform-google-service-account.git?ref=v1.0.0"
  service_account = [
    {
      name          = "test"
      display_name  = "Single Service Account"
      description   = "Single Account Description"
      roles         = ["roles/viewer"] # Single role
      generate_keys = false
    }

  ]
}


#####==============================================================================
##### instance_template module call.
#####==============================================================================
module "instance_template" {
  source               = "git::https://github.com/SyncArcs/terraform-google-template-instance.git?ref=v1.0.0"
  name                 = "template"
  environment          = "test"
  region               = "asia-northeast1"
  source_image         = "ubuntu-2204-jammy-v20230908"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  disk_size_gb         = "20"
  subnetwork           = module.subnet.subnet_id
  instance_template    = true
  service_account      = null
  ## public IP if enable_public_ip is true
  enable_public_ip = true
  metadata = {
    ssh-keys = <<EOF
      dev:ssh-rsa AAAAB3NzaC1yc2EAA/3mwt2y+PDQMU= ashish@ashish
    EOF
  }
}

resource "google_compute_instance_from_template" "vm" {
  name                     = "${var.name}-${var.environment}"
  project                  = "soy-smile-435017-c5"
  zone                     = "us-west1-a"
  source_instance_template = module.instance_template.self_link_unique
  network_interface {
    subnetwork = module.subnet.subnet_self_link
  }
}

resource "google_service_account_iam_binding" "sa_user" {
  service_account_id = "projects/soy-smile-435017-c5/serviceAccounts/${module.service-account.account_email}"
  role               = "roles/iam.serviceAccountUser"
  members            = []
}



resource "google_project_iam_member" "os_login_bindings" {
  for_each = toset([])
  project  = "soy-smile-435017-c5"
  role     = "roles/compute.osLogin"
  member   = each.key
}

#####==============================================================================
##### iap_tunneling module call.
#####==============================================================================
module "iap_tunneling" {
  source           = "../../modules/iap-tunneling"
  name             = var.name
  environment      = var.environment
  network          = module.vpc.self_link
  members          = []
  service_accounts = [module.service-account.account_email]
  instances = [{
    name = google_compute_instance_from_template.vm.name
    zone = "us-west1-a"
  }]
}