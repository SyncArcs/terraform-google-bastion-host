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


######==============================================================================
###### iap_bastion_group module call.
######==============================================================================
module "iap_bastion_group" {
  source      = "../../modules/bastion-group"
  name        = "test"
  environment = "bastion"
  region      = "us-west1"
  zone        = "us-west1-a"
  network     = module.vpc.self_link
  subnet      = module.subnet.subnet_self_link
  members     = []
  target_size = 1
}
